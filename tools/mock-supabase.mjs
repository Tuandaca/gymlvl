import http from 'node:http';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': '*',
  'Content-Type': 'application/json',
};

const user = {
  id: '00000000-0000-0000-0000-000000000001',
  aud: 'authenticated',
  role: 'authenticated',
  email: 'hunter@gymlvl.dev',
  email_confirmed_at: '2026-10-26T00:00:00.000Z',
  confirmed_at: '2026-10-26T00:00:00.000Z',
  last_sign_in_at: '2026-10-26T00:00:00.000Z',
  created_at: '2026-10-26T00:00:00.000Z',
  updated_at: '2026-10-26T00:00:00.000Z',
  app_metadata: { provider: 'email', providers: ['email'] },
  user_metadata: { full_name: 'Solo Hunter' },
  identities: [],
};

let userRecord = {
  id: user.id,
  email: user.email,
  onboarding_completed: false,
  role: 'hunter',
  created_at: '2026-10-26T00:00:00.000Z',
};

let userClasses = [
  {
    id: 'uc-1',
    user_id: user.id,
    class_id: 'warrior',
    level: 3,
    current_xp: 450,
    slot: 'primary',
  },
];

let activeWorkout = {
  id: 'w-active-1',
  user_id: user.id,
  start_time: new Date().toISOString(),
  end_time: null,
  is_completed: false,
  is_paused: false,
  total_xp: 0,
  exercises: [
    {
      id: 'we-1',
      workout_id: 'w-active-1',
      exercise_id: 'bench_press',
      order_index: 0,
      exercise: {
        id: 'bench_press',
        name: 'Barbell Bench Press',
        category: 'Chest',
        equipment: 'Barbell',
      },
      sets: [
        {
          id: 'ws-1',
          workout_exercise_id: 'we-1',
          set_number: 1,
          reps: 12,
          weight_kg: 60.0,
          is_completed: true,
        },
        {
          id: 'ws-2',
          workout_exercise_id: 'we-1',
          set_number: 2,
          reps: 10,
          weight_kg: 65.0,
          is_completed: false,
        },
      ],
    },
  ],
};

const exercisesList = [
  { id: 'bench_press', name: 'Barbell Bench Press', category: 'Chest', equipment: 'Barbell' },
  { id: 'squat', name: 'Barbell Back Squat', category: 'Legs', equipment: 'Barbell' },
  { id: 'deadlift', name: 'Conventional Deadlift', category: 'Back', equipment: 'Barbell' },
  { id: 'overhead_press', name: 'Overhead Press', category: 'Shoulders', equipment: 'Barbell' },
  { id: 'pullup', name: 'Pull-up', category: 'Back', equipment: 'Bodyweight' },
  { id: 'pushup', name: 'Push-up', category: 'Chest', equipment: 'Bodyweight' },
];

function makeJwt() {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const now = Math.floor(Date.now() / 1000);
  const payload = Buffer.from(JSON.stringify({
    sub: user.id,
    aud: 'authenticated',
    role: 'authenticated',
    email: user.email,
    iat: now,
    exp: now + 86400,
  })).toString('base64url');
  return `${header}.${payload}.sig`;
}

const server = http.createServer((req, res) => {
  console.log('MOCK-SB:', req.method, req.url);
  if (req.method === 'OPTIONS') {
    res.writeHead(200, corsHeaders).end();
    return;
  }

  const url = new URL(req.url, 'http://localhost');
  const path = url.pathname;
  let body = '';
  req.on('data', chunk => { body += chunk; });
  req.on('end', () => {
    let parsedBody = {};
    try { if (body) parsedBody = JSON.parse(body); } catch (_) {}

    // Auth endpoints
    if (path.startsWith('/auth/v1/token') || path.startsWith('/auth/v1/signup')) {
      const token = makeJwt();
      const expiresAt = Math.floor(Date.now() / 1000) + 86400;
      res.writeHead(200, corsHeaders).end(JSON.stringify({
        access_token: token,
        token_type: 'bearer',
        expires_in: 86400,
        expires_at: expiresAt,
        refresh_token: 'refresh-' + token,
        user: user,
      }));
      return;
    }

    if (path === '/auth/v1/user') {
      res.writeHead(200, corsHeaders).end(JSON.stringify(user));
      return;
    }

    if (path === '/auth/v1/logout') {
      res.writeHead(200, corsHeaders).end(JSON.stringify({}));
      return;
    }

    if (path === '/mock/set-onboarded') {
      userRecord.onboarding_completed = true;
      res.writeHead(200, corsHeaders).end(JSON.stringify({ onboarding_completed: true }));
      return;
    }

    // PostgREST: users
    if (path.startsWith('/rest/v1/users')) {
      if (req.headers['accept']?.includes('vnd.pgrst.object')) {
        res.writeHead(200, corsHeaders).end(JSON.stringify(userRecord));
      } else {
        res.writeHead(200, corsHeaders).end(JSON.stringify([userRecord]));
      }
      return;
    }

    // PostgREST: user_classes
    if (path.startsWith('/rest/v1/user_classes')) {
      res.writeHead(200, corsHeaders).end(JSON.stringify(userClasses));
      return;
    }

    // PostgREST: exercises
    if (path.startsWith('/rest/v1/exercises')) {
      res.writeHead(200, corsHeaders).end(JSON.stringify(exercisesList));
      return;
    }

    // PostgREST: workouts
    if (path.startsWith('/rest/v1/workouts')) {
      res.writeHead(200, corsHeaders).end(JSON.stringify([activeWorkout]));
      return;
    }

    // RPC endpoints
    if (path === '/rest/v1/rpc/initialize_user') {
      userRecord.onboarding_completed = true;
      res.writeHead(200, corsHeaders).end(JSON.stringify({ success: true }));
      return;
    }

    if (path === '/rest/v1/rpc/get_user_stats') {
      res.writeHead(200, corsHeaders).end(JSON.stringify({
        volume_trend: [
          { date: '2026-10-20', value: 1200 },
          { date: '2026-10-22', value: 1600 },
          { date: '2026-10-24', value: 1950 },
          { date: '2026-10-26', value: 2400 },
        ],
        muscle_split: [
          { label: 'Chest', value: 40 },
          { label: 'Back', value: 25 },
          { label: 'Legs', value: 20 },
          { label: 'Arms', value: 15 },
        ],
        recent_prs: [
          {
            exercises: { name: 'Barbell Bench Press' },
            max_weight_kg: 85.0,
            updated_at: '2026-10-25T10:00:00.000Z',
          },
        ],
        streak: { current_streak: 7, last_workout_date: '2026-10-26' },
        achievements: [
          { id: 'first_step', title: 'Thợ săn sơ cấp', description: 'Hoàn thành ngày tập đầu tiên', unlocked: true },
        ],
      }));
      return;
    }

    if (path === '/rest/v1/rpc/sync_daily_data') {
      res.writeHead(200, corsHeaders).end(JSON.stringify({
        quest: {
          id: 'quest-today',
          user_id: user.id,
          quest_id: 'daily_hunter_quest',
          status: 'active',
          expires_at: '2026-10-27T23:59:59.000Z',
          config: [
            {
              exercise_id: 'bench_press',
              exercise_name: 'Barbell Bench Press',
              sets: 3,
              reps: 10,
              weight_kg: 60,
            },
            {
              exercise_id: 'pushup',
              exercise_name: 'Push-up',
              sets: 3,
              reps: 15,
              weight_kg: 0,
            },
          ],
        },
      }));
      return;
    }

    if (path === '/rest/v1/rpc/start_workout' || path === '/rest/v1/rpc/get_active_workout') {
      res.writeHead(200, corsHeaders).end(JSON.stringify(activeWorkout));
      return;
    }

    if (path === '/rest/v1/rpc/begin_workout') {
      activeWorkout.start_time = new Date().toISOString();
      res.writeHead(200, corsHeaders).end(JSON.stringify(activeWorkout));
      return;
    }

    if (path === '/rest/v1/rpc/set_workout_paused') {
      activeWorkout.is_paused = Boolean(parsedBody.p_paused);
      res.writeHead(200, corsHeaders).end(JSON.stringify(activeWorkout));
      return;
    }

    if (path === '/rest/v1/rpc/update_workout_set') {
      res.writeHead(200, corsHeaders).end(JSON.stringify(activeWorkout));
      return;
    }

    if (path === '/rest/v1/rpc/complete_workout') {
      activeWorkout.is_completed = true;
      res.writeHead(200, corsHeaders).end(JSON.stringify({
        xp_awarded: 250,
        new_level: 4,
        streak_count: 8,
        leveled_up: true,
      }));
      return;
    }

    // Edge Functions: AI Coach
    if (path.includes('ai-coach')) {
      res.writeHead(200, corsHeaders).end(JSON.stringify({
        reply: 'Chào Thợ Săn! Thể lực của bạn đang ở mức rất tốt. Buổi tập Ngực và Vai hôm nay hãy duy trì nhịp thở đều và chú ý giữ thẳng lưng khi nâng tạ nhé!',
      }));
      return;
    }

    // Default fallback
    res.writeHead(200, corsHeaders).end(JSON.stringify([]));
  });
});

server.listen(54321, '127.0.0.1', () => {
  console.log('Mock Supabase backend listening at http://127.0.0.1:54321');
});
