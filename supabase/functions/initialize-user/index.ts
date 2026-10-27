import { rpcHandler } from "../_shared/http.ts";
Deno.serve(rpcHandler("initialize_user", body => ({p_profile: body.profile ?? body})));
