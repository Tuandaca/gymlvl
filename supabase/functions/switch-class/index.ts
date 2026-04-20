import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { CLASS_FOCUS_CATEGORIES, xpRequiredForClassLevel } from "../_shared/progression_engine.ts";

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
    const token = authHeader.replace('Bearer ', '');

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    if (userError || !user) throw new Error('Unauthorized');

    const { new_class_id, slot } = await req.json();
    if (!new_class_id || !slot) throw new Error('Missing new_class_id or slot');
    if (slot !== 'primary' && slot !== 'secondary') throw new Error('Invalid slot');

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. Validate new_class_id
    const { data: classDef, error: classDefError } = await supabaseAdmin
      .from('class_definitions')
      .select('*')
      .eq('class_id', new_class_id)
      .single();

    if (classDefError || !classDef) throw new Error('Invalid class ID');

    // 2. Check if class is already equipped in another slot
    const { data: existingSlots } = await supabaseAdmin
      .from('user_classes')
      .select('slot, class_id')
      .eq('user_id', user.id);

    if (existingSlots) {
      const conflict = existingSlots.find(s => s.class_id === new_class_id && s.slot !== slot);
      if (conflict) {
        throw new Error('Class already equipped in another slot. Please swap them properly.');
      }
    }

    // 3. Retrospective XP Calculation
    // We get all completed sets for the user, joined with exercise categories.
    // Since Supabase JS API doesn't easily do nested aggregations matching focus categories, 
    // we'll run a RPC or fetch raw data. Since data is currently small, we can fetch their completed workouts.
    
    // Actually, getting all workout exercises for a user involves a few joins.
    // Let's do a simplified query: fetch all workout_sets that are completed and belong to this user.
    // To do this via JS without RPC:
    // workouts eq user_id -> inner join workout_exercises -> inner join exercises
    
    const { data: historyData, error: historyError } = await supabaseAdmin
      .from('workout_sets')
      .select(`
        weight_kg,
        baseline_weight_kg,
        workout_exercises!inner(
          exercises!inner(category),
          workouts!inner(user_id)
        )
      `)
      .eq('is_completed', true)
      .eq('workout_exercises.workouts.user_id', user.id);

    if (historyError) throw new Error('Failed to fetch history: ' + historyError.message);

    let retrospectiveXP = 0;
    const focusCategories = CLASS_FOCUS_CATEGORIES[new_class_id] || [];

    if (historyData) {
      for (const set of historyData) {
        // Safe access due to inner joins
        const category = ((set.workout_exercises as any)?.exercises?.category || '').toLowerCase();
        
        // If the set category matches the class focus, grant 100% XP. If it doesn't match, grant 40% XP.
        const focusRatio = focusCategories.includes(category) ? 1.0 : 0.4;
        
        const actualWeight = parseFloat(set.weight_kg) || 0;
        const baselineWeight = parseFloat(set.baseline_weight_kg) || 0;
        
        let setXP = 5;
        if (baselineWeight > 0) {
          const effortRatio = actualWeight / baselineWeight;
          const safeRatio = Math.min(Math.max(effortRatio, 0.2), 3.0);
          setXP = 5 * safeRatio;
        } else if (actualWeight > 0) {
          setXP = 5;
        }
        
        retrospectiveXP += (setXP * focusRatio);
      }
    }

    // Floor the XP
    retrospectiveXP = Math.floor(retrospectiveXP);

    // 4. Calculate Level
    let newLevel = 1;
    while (retrospectiveXP >= xpRequiredForClassLevel(newLevel, classDef.difficulty)) {
      newLevel++;
    }

    if (newLevel > 20) newLevel = 20; // Hard cap at Lv20 for classes

    // 5. Upsert to user_classes
    const { error: upsertError } = await supabaseAdmin
      .from('user_classes')
      .upsert({
        user_id: user.id,
        class_id: new_class_id,
        class_name: classDef.class_name,
        slot: slot,
        difficulty: classDef.difficulty,
        current_xp: retrospectiveXP,
        level: newLevel,
        is_graduated: newLevel === 20,
        updated_at: new Date().toISOString()
      }, { onConflict: 'user_id,slot' });

    if (upsertError) throw new Error('Failed to update class: ' + upsertError.message);

    return new Response(JSON.stringify({ 
      success: true, 
      class_id: new_class_id, 
      xp_granted: retrospectiveXP, 
      level: newLevel 
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    console.error('Error switching class:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
