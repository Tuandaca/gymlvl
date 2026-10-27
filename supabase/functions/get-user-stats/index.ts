import { rpcHandler } from "../_shared/http.ts";
Deno.serve(rpcHandler("get_user_stats"));
