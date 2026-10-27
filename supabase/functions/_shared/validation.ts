export class HttpError extends Error {
  constructor(public status: number, message: string) { super(message); }
}
export function bearerToken(header: string | null): string {
  const match = header?.match(/^Bearer\s+([^\s]+)$/i);
  if (!match) throw new HttpError(401, "Sign in to continue.");
  return match[1];
}
export function uuid(value: unknown): string {
  if (typeof value !== "string" || !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) throw new HttpError(400, "A valid workout ID is required.");
  return value;
}
export function databaseError(error: { code?: string }): HttpError {
  if (error.code === "42501") return new HttpError(403, "You cannot access this operation.");
  if (error.code?.startsWith("22") || error.code?.startsWith("23")) return new HttpError(400, "Check the submitted information and try again.");
  return new HttpError(503, "The service is unavailable. Please try again.");
}
