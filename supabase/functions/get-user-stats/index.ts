import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

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
    if (!authHeader) throw new Error('Missing Authorization header');

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) throw new Error('Unauthorized');

    // 1. Lấy dữ liệu 7 ngày gần nhất
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const { data: workouts, error: workoutError } = await supabaseAdmin
      .from('workouts')
      .select(`
        id,
        completed_at,
        workout_exercises (
          id,
          exercise_id,
          exercises (category),
          workout_sets ( weight_kg, reps, is_completed )
        )
      `)
      .eq('user_id', user.id)
      .eq('status', 'completed')
      .gte('completed_at', sevenDaysAgo.toISOString())
      .order('completed_at', { ascending: true });

    if (workoutError) throw workoutError;

    // 2. Xử lý biểu đồ Volume (Khối lượng theo ngày)
    const volumeData: Record<string, number> = {};
    // Init 7 days with 0
    for (let i = 0; i < 7; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      volumeData[dateStr] = 0;
    }

    // 3. Xử lý biểu đồ Radar (Phân bổ nhóm cơ)
    const muscleUsage: Record<string, number> = {
      'Chest': 0, 'Back': 0, 'Legs': 0, 'Shoulders': 0, 'Arms': 0, 'Core': 0
    };

    workouts?.forEach(workout => {
      const dateStr = new Date(workout.completed_at).toISOString().split('T')[0];
      let dailyVolume = 0;

      workout.workout_exercises.forEach(we => {
        const category = we.exercises?.category || 'Other';
        let exerciseVolume = 0;

        we.workout_sets.forEach(set => {
          if (set.is_completed) {
            const vol = (set.weight_kg || 0) * (set.reps || 0);
            exerciseVolume += vol;
          }
        });

        dailyVolume += exerciseVolume;
        
        // Map category sang 6 nhóm chính (Dễ dàng thay đổi mapping ở đây)
        if (muscleUsage.hasOwnProperty(category)) {
          muscleUsage[category] += exerciseVolume;
        } else {
          // Fallback mapping cho các bài tập lẻ
          if (category.toLowerCase().includes('chest')) muscleUsage['Chest'] += exerciseVolume;
          else if (category.toLowerCase().includes('back')) muscleUsage['Back'] += exerciseVolume;
          else if (category.toLowerCase().includes('leg')) muscleUsage['Legs'] += exerciseVolume;
          else if (category.toLowerCase().includes('shoulder')) muscleUsage['Shoulders'] += exerciseVolume;
          else if (category.toLowerCase().includes('arm')) muscleUsage['Arms'] += exerciseVolume;
          else if (category.toLowerCase().includes('core')) muscleUsage['Core'] += exerciseVolume;
        }
      });

      if (volumeData.hasOwnProperty(dateStr)) {
        volumeData[dateStr] += dailyVolume;
      }
    });

    // 4. Lấy PRs gần đây để show Strength Trend
    const { data: prs } = await supabaseAdmin
      .from('exercise_prs')
      .select('exercise_id, exercises(name), max_weight_kg, updated_at')
      .eq('user_id', user.id)
      .order('updated_at', { ascending: false })
      .limit(5);

    return new Response(JSON.stringify({
      volume_trend: Object.entries(volumeData).sort().map(([date, value]) => ({ date, value })),
      muscle_split: Object.entries(muscleUsage).map(([label, value]) => ({ label, value })),
      recent_prs: prs
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
