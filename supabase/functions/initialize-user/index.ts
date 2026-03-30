// @ts-nocheck
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Check if the request has an authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing Authorization header');
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // Lấy user gọi request hiện tại
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) throw new Error('Unauthorized')

    // Parse Body
    const bodyText = await req.text();
    const { experience_level } = bodyText ? JSON.parse(bodyText) : { experience_level: 'beginner' };

    // Xác định level khởi đầu
    let initialLevel = 1;
    let initialTitle = 'Tân Sinh Phấn Tạ';

    if (experience_level === 'intermediate') {
      initialLevel = 11;
      initialTitle = 'Kẻ Săn Cơ';
    } else if (experience_level === 'advanced') {
      initialLevel = 21;
      initialTitle = 'Tay Tạ Sắt';
    }

    // Bơm auth làm admin để phá RLS update/insert bảng public.users 
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Upsert bảng `users` (Đảm bảo có record kể cả khi trigger tạo user bị disable)
    const { error: upsertError } = await supabaseAdmin
      .from('users')
      .upsert({
        id: user.id,
        email: user.email,
        display_name: user.user_metadata?.full_name ?? (user.email ? user.email.split('@')[0] : 'User'),
        onboarding_completed: true,
        level: initialLevel,
        current_title: initialTitle,
        is_capped: false,
        overflow_xp: 0
      })

    if (upsertError) throw upsertError

    return new Response(
      JSON.stringify({ 
        message: 'Onboarding complete', 
        setup: { level: initialLevel, title: initialTitle }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
