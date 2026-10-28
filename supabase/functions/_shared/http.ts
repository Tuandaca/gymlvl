import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { bearerToken, databaseError, HttpError } from "./validation.ts";
import { BodyTooLargeError, readBoundedText } from "./bounded_body.ts";
export { HttpError } from "./validation.ts";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
export function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), { status, headers: { ...corsHeaders, "Content-Type": "application/json" } });
}
export function errorResponse(error: unknown): Response {
  return error instanceof HttpError ? jsonResponse({ error: error.message }, error.status) : jsonResponse({ error: "The service is unavailable. Please try again." }, 503);
}
export function requirePost(req: Request): void {
  if (req.method !== "POST") throw new HttpError(405, "Use POST for this operation.");
}
export async function authenticateRequest(req: Request) {
  const token = bearerToken(req.headers.get("Authorization"));
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
  if (!url || !key) throw new HttpError(503, "Service configuration is unavailable.");
  const client = createClient(url, key, { global: { headers: { Authorization: `Bearer ${token}` } }, auth: { persistSession: false, autoRefreshToken: false } });
  const { data, error } = await client.auth.getUser(token);
  if (error || !data.user) throw new HttpError(401, "Your session expired. Please sign in again.");
  return client;
}
export function rpcHandler(name: string, parameters: (body: Record<string, unknown>) => Record<string, unknown> = () => ({})) {
  return async (req: Request): Promise<Response> => {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
    try {
      requirePost(req);
      const client = await authenticateRequest(req);
      let body: Record<string, unknown> = {};
      let text: string;
      try { text = await readBoundedText(req.body, 16384); } catch (error) {
        if (error instanceof BodyTooLargeError) throw new HttpError(413, "Request is too large.");
        throw error;
      }
      if (text) {
        try { body = JSON.parse(text); } catch { throw new HttpError(400, "Invalid JSON request."); }
        if (!body || typeof body !== "object" || Array.isArray(body)) throw new HttpError(400, "Invalid request.");
      }
      const { data, error } = await client.rpc(name, parameters(body));
      if (error) throw databaseError(error);
      return jsonResponse(data);
    } catch (error) { return errorResponse(error); }
  };
}
