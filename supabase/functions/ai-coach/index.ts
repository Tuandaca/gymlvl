import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { handleCoachRequest } from "./service.ts";

Deno.serve((req: Request) => {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
  if (!url || !key) return Response.json({
    code: "coach_unavailable",
    error: "coach_temporarily_unavailable",
    advice: "Focus on proper form, steady hydration, and progressive overload while the coach is resting.",
  }, {
    status: 503, headers: { "Access-Control-Allow-Origin": "*" },
  });
  const client = createClient(url, key, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    auth: { persistSession: false },
  });
  let userId: string;
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  const coachKey = Deno.env.get("COACH_API_KEY") ?? geminiKey;
  const defaultUrl = geminiKey ? "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" : undefined;
  const defaultModel = geminiKey ? "gemini-1.5-flash" : undefined;

  return handleCoachRequest(req, {
    authenticate: async (token) => {
      const { data, error } = await client.auth.getUser(token);
      userId = data.user?.id ?? "";
      return !error && !!userId;
    },
    consumeQuota: async () => {
      const { data, error } = await client.rpc("consume_coach_request");
      if (error) throw error;
      return data === true;
    },
    context: async () => {
      const since = new Date(Date.now() - 7 * 86400000).toISOString();
      const [profile, workouts] = await Promise.all([
        client.from("profiles").select("environment,goals,experience_level,weekly_gym_days,weekly_home_days").eq("id", userId).maybeSingle(),
        client.from("workouts").select("completed_at,duration_seconds,workout_exercises(exercises(name,category),workout_sets(reps,weight_kg,is_completed))")
          .eq("user_id", userId).eq("status", "completed").gte("completed_at", since).order("completed_at", { ascending: false }).limit(7),
      ]);
      if (profile.error || workouts.error) throw new Error("context_unavailable");
      return { profile: profile.data, recentCompletedWorkouts: workouts.data };
    },
    providerUrl: Deno.env.get("COACH_API_URL") ?? defaultUrl,
    providerKey: coachKey,
    model: Deno.env.get("COACH_MODEL") ?? defaultModel,
  });
});
