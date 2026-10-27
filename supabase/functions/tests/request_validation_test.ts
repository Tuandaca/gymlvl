import { bearerToken, databaseError, HttpError, uuid } from "../_shared/validation.ts";
function equal(actual: unknown, expected: unknown) { if (actual !== expected) throw new Error(`Expected ${expected}, received ${actual}`); }
function rejects(run: () => unknown, status: number) {
  try { run(); } catch (error) { if (!(error instanceof HttpError)) throw error; equal(error.status, status); return; }
  throw new Error("Expected request rejection");
}
Deno.test("Only a nonempty Bearer credential is accepted", () => {
  for (const input of [null, "", "Basic secret", "Bearer", "Bearer a b"]) rejects(() => bearerToken(input), 401);
  equal(bearerToken("Bearer signed-user-token"), "signed-user-token");
  equal(bearerToken("bearer signed-user-token"), "signed-user-token");
});
Deno.test("Workout identifiers are validated before database access", () => {
  for (const input of [null, 7, {}, "", "not-a-uuid"]) rejects(() => uuid(input), 400);
  equal(uuid("12345678-1234-1234-1234-123456789012"), "12345678-1234-1234-1234-123456789012");
});
Deno.test("Database failures expose stable sanitized errors", () => {
  equal(databaseError({ code: "42501" }).status, 403);
  equal(databaseError({ code: "23514" }).status, 400);
  equal(databaseError({ code: "22023" }).status, 400);
  equal(databaseError({ code: "XX000" }).status, 503);
  equal(databaseError({}).message, "The service is unavailable. Please try again.");
});
