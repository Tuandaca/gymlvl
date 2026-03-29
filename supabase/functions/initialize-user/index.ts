import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // Lấy user gọi request hiện tại
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) throw new Error('Unauthorized')

    // Parse Body
    const { experience_level } = await req.json()

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

    // Bơm auth làm admin để phá RLS update bảng public.users 
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Cập nhật bảng `users`
    const { error: updateError } = await supabaseAdmin
      .from('users')
      .update({
        onboarding_completed: true,
        level: initialLevel,
        current_title: initialTitle,
        is_capped: false,
        overflow_xp: 0
      })
      .eq('id', user.id)

    if (updateError) throw updateError

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
