import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { validateWorkout, calculateXP, checkLevel, verifyQuestCompletion } from "../_shared/progression_engine.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      console.error('Missing Authorization header');
      throw new Error('Missing Authorization header');
    }

    const token = authHeader.replace('Bearer ', '');
    console.log('Processing request for token starts with:', token.substring(0, 10));

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    
    if (userError || !user) {
      console.error('Auth error detail:', userError);
      throw new Error(`Unauthorized: ${userError?.message || 'Empty user'}`);
    }
    
    console.log('User authenticated:', user.id);

    const { workout_id } = await req.json();
    if (!workout_id) throw new Error('Missing workout_id parameter');

    // Dùng Service Role để đọc và update database chống RLS cho các trường cấm
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Lấy workout kèm bài tập và sets
    const { data: workout, error: workoutError } = await supabaseAdmin
      .from('workouts')
      .select(`
        *,
        workout_exercises(
          *,
          exercises(category),
          workout_sets(*)
        )
      `)
      .eq('id', workout_id)
      .eq('user_id', user.id)
      .single();

    if (workoutError || !workout) throw new Error('Workout not found or access denied');
    if (workout.status !== 'completed') throw new Error('Workout is not completed yet');
    // Chống cheat: Đã nhận điểm rồi thì báo lỗi
    if (workout.is_xp_calculated) throw new Error('XP already calculated for this workout');

    // 1. Anti-cheat validation
    const validation = validateWorkout(workout);
    if (!validation.valid) {
      return new Response(
        JSON.stringify({ error: 'Anti-cheat violation', details: validation.errors }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // 2. Lấy profile
    const { data: userProfile, error: profileError } = await supabaseAdmin
      .from('users')
      .select('level, total_xp, current_level_xp')
      .eq('id', user.id)
      .single();

    if (profileError || !userProfile) throw new Error('User profile not found');

    // ... (authenticating user and fetching profile)
    
    // 3. Kiểm tra Quest active cho hôm nay
    const today = new Date();
    today.setHours(today.getHours() + 7);
    const dateStr = today.toISOString().split('T')[0];

    const { data: activeQuest } = await supabaseAdmin
      .from('quest_instances')
      .select('*')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .gte('created_at', `${dateStr}T00:00:00Z`)
      .lte('created_at', `${dateStr}T23:59:59Z`)
      .maybeSingle();

    const isQuest = activeQuest ? verifyQuestCompletion(workout, activeQuest.prescribed_config) : false;
    
    // TODO: Gắn logic lấy streak từ bảng streaks (Phase 2.6)
    const userStreak = 0;

    console.log(`Calculating XP for workout ${workout_id}, user ${user.id}. isQuest: ${isQuest}`);
    
    const earnedXP = calculateXP(workout, {
      userStreak,
      isSuspicious: validation.isSuspicious,
      isQuest
    });

    console.log(`Earned XP: ${earnedXP}, isSuspicious: ${validation.isSuspicious}`);
    
    const newTotalXP = (userProfile.total_xp || 0) + earnedXP;

    // 4. Kiểm tra Level up
    const { newLevel, leveledUp, nextLevelXp } = checkLevel(userProfile.level || 1, newTotalXP);
    
    // 5. Cập nhật DB (Sử dụng Promise.all để song song hóa)
    const updates = [];
    const title = leveledUp ? getTitleForLevel(newLevel) : undefined;
    
    // Cập nhật User Profile
    updates.push(supabaseAdmin.from('users').update({
      total_xp: newTotalXP,
      level: newLevel,
      current_level_xp: newTotalXP - (newLevel > 1 ? Math.floor(100 * Math.pow(newLevel - 1, 1.5)) : 0),
      ...(title ? { current_title: title } : {})
    }).eq('id', user.id));

    // Đánh dấu workout đã tính điểm
    updates.push(supabaseAdmin.from('workouts').update({ is_xp_calculated: true }).eq('id', workout_id));

    // Log XP
    updates.push(supabaseAdmin.from('xp_logs').insert({
      user_id: user.id,
      amount: earnedXP,
      source: isQuest ? 'quest' : 'workout',
      source_id: workout_id,
    }));

    // Cập nhật Quest status nếu hoàn thành
    if (isQuest && activeQuest) {
      updates.push(supabaseAdmin.from('quest_instances').update({
        status: 'completed',
        completed_at: new Date().toISOString(),
        earned_xp: earnedXP
      }).eq('id', activeQuest.id));
    }

    // 6. CẬP NHẬT KỶ LỤC CÁ NHÂN (PRs)
    if (workout.workout_exercises) {
      for (const we of workout.workout_exercises) {
        if (!we.workout_sets) continue;
        const maxWeight = Math.max(...we.workout_sets.filter(s => s.is_completed).map(s => Number(s.weight_kg || 0)));
        if (maxWeight > 0) {
          updates.push(supabaseAdmin.rpc('upsert_exercise_pr', {
            p_user_id: user.id,
            p_exercise_id: we.exercise_id,
            p_weight: maxWeight
          }));
        }
      }
    }

    await Promise.all(updates);
    console.log('Database updates successful');

    return new Response(
      JSON.stringify({
        message: 'XP calculation success',
        earnedXP,
        totalXP: newTotalXP,
        newLevel,
        leveledUp,
        isQuest,
        newTitle: title || null,
        nextLevelXp,
        isSuspicious: validation.isSuspicious,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});

function getTitleForLevel(level: number): string | null {
  if (level >= 100) return "Bất Tử";
  if (level >= 75) return "Thần Thoại";
  if (level >= 50) return "Huyền Thoại";
  if (level >= 30) return "Anh Hùng";
  if (level >= 20) return "Dũng Sĩ";
  if (level >= 15) return "Đấu Sĩ";
  if (level >= 10) return "Chiến Binh";
  if (level >= 5) return "Tập Sự";
  return null;
}
