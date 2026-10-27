import { rpcHandler, HttpError } from "../_shared/http.ts";
Deno.serve(rpcHandler("switch_class", body => {
 if (typeof body.new_class_id !== "string" || !/^[A-F]$/.test(body.new_class_id) || !["primary","secondary"].includes(String(body.slot))) throw new HttpError(400,"Choose a valid class and slot.");
 return {p_new_class_id: body.new_class_id, p_slot: body.slot};
}));
