import { jsonResponse, corsHeaders } from "../_shared/http.ts";

// delete-account: server-side account deletion boundary.
//
// Caller JWT is verified by Supabase Gateway (verify_jwt = true). The
// authenticated user's GymLvl data is removed via the delete_account_data
// RPC, then the auth.users row is removed using the service_role credential
// (read from environment, never embedded in client code).
//
// The service_role key is operator-supplied and never committed to the
// repository. If it is unset, data deletion still occurs but the auth user
// row is left in place and the caller receives a sanitized advisory.
//
// There is no distributed transaction across PostgreSQL public data and
// Supabase Auth. Public-data deletion is idempotent (delete_account_data
// removes only the caller's own rows and is safe to retry); if Auth deletion
// fails, the caller receives a 202 advisory so the operator can complete
// cleanup, and retrying is safe.

export interface DeleteAccountDeps {
  authenticate: (token: string) => Promise<string | null>;
  envGet: (key: string) => string | undefined;
  rpcDeleteAccount: (uid: string, token: string) => Promise<{ error: unknown }>;
  adminDeleteUser: (uid: string) => Promise<{ error: unknown }>;
}

export async function handleDeleteAccount(req: Request, deps: DeleteAccountDeps): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ code: "method_not_allowed", error: "method_not_allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const token = req.headers.get("Authorization")?.match(/^Bearer\s+(\S+)$/i)?.[1];
  if (!token) {
    return new Response(
      JSON.stringify({ code: "unauthorized", error: "unauthorized" }),
      { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const uid = await deps.authenticate(token);
  if (uid === null) {
    return new Response(
      JSON.stringify({ code: "unauthorized", error: "unauthorized" }),
      { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  // Remove all user-owned GymLvl data via the owner-scoped RPC. Idempotent:
  // retrying after a partial failure removes nothing additional and is safe.
  const { error: deleteError } = await deps.rpcDeleteAccount(uid, token);
  if (deleteError) {
    return new Response(
      JSON.stringify({ code: "deletion_failed", error: "account_deletion_failed" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  // Remove the auth.users row using the operator-owned service_role key.
  // This key must be provided through environment configuration; it is never
  // embedded in client code or committed to the repository.
  const serviceRoleKey = deps.envGet("SUPABASE_SERVICE_ROLE_KEY");
  if (serviceRoleKey) {
    const { error: adminError } = await deps.adminDeleteUser(uid);
    if (adminError) {
      // Data was deleted but the auth row remains. Report a sanitized
      // advisory so the operator can complete cleanup without leaking internals.
      return new Response(
        JSON.stringify({
          code: "auth_row_removal_deferred",
          error: "account_data_deleted_auth_removal_pending",
          advice: "User data was deleted. Operator must remove the auth account via the Supabase dashboard.",
        }),
        { status: 202, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
  } else {
    return new Response(
      JSON.stringify({
        code: "auth_row_removal_deferred",
        error: "account_data_deleted_auth_removal_pending",
        advice: "User data was deleted. Configure SUPABASE_SERVICE_ROLE_KEY and retry to remove the auth account.",
      }),
      { status: 202, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  return new Response(
    JSON.stringify({
      code: "account_deleted",
      message: "Account deleted successfully",
      user_id: uid,
    }),
    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

const realDeps: DeleteAccountDeps = {
  authenticate: async (token) => {
    const url = Deno.env.get("SUPABASE_URL");
    const key = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
    if (!url || !key) return null;
    // deno-lint-ignore no-explicit-any
    const { createClient }: any = await import("https://esm.sh/@supabase/supabase-js@2.39.3");
    const client = createClient(url, key, {
      global: { headers: { Authorization: `Bearer ${token}` } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data, error } = await client.auth.getUser(token);
    return error || !data.user ? null : data.user.id;
  },
  envGet: (key) => Deno.env.get(key),
  rpcDeleteAccount: async (uid, token) => {
    const url = Deno.env.get("SUPABASE_URL");
    const key = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
    if (!url || !key) return { error: new Error("service_unavailable") };
    // deno-lint-ignore no-explicit-any
    const { createClient }: any = await import("https://esm.sh/@supabase/supabase-js@2.39.3");
    const client = createClient(url, key, {
      global: { headers: { Authorization: `Bearer ${token}` } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { error } = await client.rpc("delete_account_data");
    return { error };
  },
  adminDeleteUser: async (uid) => {
    const url = Deno.env.get("SUPABASE_URL");
    const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !key) return { error: new Error("no_service_role_key") };
    // deno-lint-ignore no-explicit-any
    const { createClient }: any = await import("https://esm.sh/@supabase/supabase-js@2.39.3");
    const client = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
    const { error } = await client.auth.admin.deleteUser(uid);
    return { error };
  },
};

Deno.serve((req) => handleDeleteAccount(req, realDeps));
