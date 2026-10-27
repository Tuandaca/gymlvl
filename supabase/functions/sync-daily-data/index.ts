import { rpcHandler } from "../_shared/http.ts";
Deno.serve(rpcHandler("sync_daily_data"));
