import { rpcHandler } from "../_shared/http.ts";
import { uuid } from "../_shared/validation.ts";
// Compatibility endpoint; PostgreSQL owns completion and replay.
Deno.serve(rpcHandler("complete_workout", body => ({p_workout_id: uuid(body.workout_id)})));
