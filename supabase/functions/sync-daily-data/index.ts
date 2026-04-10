import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { getSuggestedWeight } from "../_shared/progression_engine.ts";

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

    // 1. Kiểm tra xem hôm nay đã có quest chưa (Theo giờ VN UTC+7)
    const today = new Date();
    today.setHours(today.getHours() + 7);
    const dateStr = today.toISOString().split('T')[0];

    const { data: existingQuest, error: questCheckError } = await supabaseAdmin
      .from('quest_instances')
      .select('id')
      .eq('user_id', user.id)
      .gte('created_at', `${dateStr}T00:00:00Z`)
      .lte('created_at', `${dateStr}T23:59:59Z`)
      .maybeSingle();

    if (existingQuest) {
      return new Response(JSON.stringify({ message: 'Quest already exists for today', quest_id: existingQuest.id }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 2. Lấy profile và PRs để cá nhân hóa
    const { data: profile } = await supabaseAdmin.from('profiles').select('*').eq('id', user.id).single();
    const { data: prs } = await supabaseAdmin.from('exercise_prs').select('*').eq('user_id', user.id);

    // 3. Chọn Quest Template dựa trên ngày rảnh (Cơ chế xoay vòng Push-Pull-Legs cho đơn giản hóa)
    // Tương lai: Có thể AI dựa trên preferred_days để chọn template phù hợp
    const { data: templates } = await supabaseAdmin.from('quests').select('*').eq('type', 'daily_routine');
    if (!templates || templates.length === 0) throw new Error('No quest templates found');

    // Chọn template ngẫu nhiên hoặc theo thứ tự
    const template = templates[Math.floor(Math.random() * templates.length)];

    // 4. Lấy danh sách bài tập phù hợp với category của Quest
    const { data: exercises } = await supabaseAdmin
      .from('exercises')
      .select('*')
      .ilike('category', `%${template.category}%`)
      .limit(4);

    if (!exercises || exercises.length === 0) throw new Error('No exercises found for this category');

    // 5. Tính toán mức tạ cá nhân hóa (Personalization Logic)
    const prescribed_config = exercises.map(ex => {
      const userPR = prs?.find(p => p.exercise_id === ex.id);
      let targetWeight = 0;

      if (userPR && userPR.is_confirmed) {
        // AI Phase: Dùng PR thực tế (80% cường độ)
        targetWeight = Math.round(Number(userPR.max_weight_kg) * 0.8 * 2) / 2;
      } else {
        // Discovery Phase: Dùng công thức sinh trắc học
        targetWeight = getSuggestedWeight(profile, ex);
      }

      return {
        exercise_id: ex.id,
        exercise_name: ex.name,
        sets: 3,
        reps: 12,
        weight_kg: targetWeight
      };
    });

    // 6. Tạo Quest Instance
    const expiresAt = new Date();
    expiresAt.setHours(23, 59, 59, 999);

    const { data: newQuest, error: insertError } = await supabaseAdmin
      .from('quest_instances')
      .insert({
        user_id: user.id,
        quest_id: template.id,
        prescribed_config,
        expires_at: expiresAt.toISOString(),
        status: 'active'
      })
      .select()
      .single();

    if (insertError) throw insertError;

    // 7. Reset Streak nếu cần (Nếu ngày qua không tập)
    // TODO: Implement sophisticated streak logic

    return new Response(JSON.stringify({ 
      message: 'New quest generated', 
      quest: newQuest,
      isDiscovery: !prs?.some(p => p.is_confirmed)
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
