export class BodyTooLargeError extends Error {
  constructor() { super("Body exceeds byte limit."); this.name = "BodyTooLargeError"; }
}

// Header values are untrusted. Count actual bytes before decoding or retaining a chunk.
// At most maxBytes are decoded; the stream may deliver one oversize chunk before rejection.
export async function readBoundedText(body: ReadableStream<Uint8Array> | null, maxBytes: number): Promise<string> {
  if (!Number.isSafeInteger(maxBytes) || maxBytes < 0) throw new RangeError("Invalid byte limit.");
  if (!body) return "";
  const reader = body.getReader();
  const decoder = new TextDecoder();
  let bytes = 0;
  let text = "";
  try {
    while (true) {
      const { value, done } = await reader.read();
      if (done) return text + decoder.decode();
      bytes += value.byteLength;
      if (bytes > maxBytes) throw new BodyTooLargeError();
      text += decoder.decode(value, { stream: true });
    }
  } catch (error) {
    try { await reader.cancel(); } catch { /* Preserve the original sanitized failure path. */ }
    throw error;
  } finally {
    reader.releaseLock();
  }
}

export async function cancelBody(body: ReadableStream<Uint8Array> | null): Promise<void> {
  try { await body?.cancel(); } catch { /* An upstream error body is never exposed. */ }
}
