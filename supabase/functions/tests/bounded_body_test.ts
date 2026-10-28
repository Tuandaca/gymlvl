import { rpcHandler } from "../_shared/http.ts";
import { handleCoachRequest, type CoachDependencies } from "../ai-coach/service.ts";
import { BodyTooLargeError, readBoundedText } from "../_shared/bounded_body.ts";

const encoder = new TextEncoder();
function equal(actual: unknown, expected: unknown) {
  if (actual !== expected) throw new Error(`Expected ${expected}, got ${actual}`);
}
function counted(text: string, chunkSize = 1024) {
  const bytes = encoder.encode(text);
  const state = { bytes: 0, canceled: 0 };
  const stream = new ReadableStream<Uint8Array>({
    pull(controller) {
      if (state.bytes === bytes.length) { controller.close(); return; }
      const end = Math.min(bytes.length, state.bytes + chunkSize);
      controller.enqueue(bytes.slice(state.bytes, end));
      state.bytes = end;
    },
    cancel() { state.canceled++; },
  }, { highWaterMark: 0 });
  return { stream, state, total: bytes.length };
}
function padded(value: unknown, size: number) {
  const text = JSON.stringify(value);
  return text + " ".repeat(size - encoder.encode(text).length);
}
const req = (body: ReadableStream<Uint8Array>, length?: string, token = "valid") =>
  new Request("https://functions.example.test/operation", {
    method: "POST", body,
    headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(length === undefined ? {} : { "Content-Length": length }) },
  });
const user = { id: "11111111-1111-4111-8111-111111111111", aud: "authenticated", role: "authenticated" };
const deps = (overrides: Partial<CoachDependencies> = {}): CoachDependencies => ({
  authenticate: () => Promise.resolve(true), consumeQuota: () => Promise.resolve(true),
  context: () => Promise.resolve({}), providerUrl: "https://provider.invalid/chat",
  providerKey: "synthetic-provider-key", model: "synthetic-model",
  fetcher: () => Promise.resolve(Response.json({ choices: [{ message: { content: "Nghỉ ngơi. Rest." } }] })),
  ...overrides,
});
async function rpcFetch(verify: (calls: { rpc: number }) => Promise<void>, authorized = true) {
  const original = globalThis.fetch;
  const calls = { rpc: 0 };
  globalThis.fetch = (input) => {
    const url = input instanceof Request ? input.url : String(input);
    if (url.endsWith("/auth/v1/user")) return Promise.resolve(authorized
      ? Response.json(user) : Response.json({ message: "synthetic rejection" }, { status: 401 }));
    equal(url.endsWith("/rest/v1/rpc/start_workout"), true);
    calls.rpc++;
    return Promise.resolve(Response.json({ ok: true }));
  };
  try { await verify(calls); } finally { globalThis.fetch = original; }
}

for (const [name, limit] of [["RPC", 16384], ["Coach", 20000]] as const) {
  const value = name === "RPC" ? { message: "Tập luyện. Training." } : { message: "Tập luyện. Training.", history: [] };
  async function handle(request: Request, overrides: Partial<CoachDependencies> = {}) {
    return name === "RPC" ? await rpcHandler("start_workout")(request) : await handleCoachRequest(request, deps(overrides));
  }
  async function isolated(verify: () => Promise<void>) {
    if (name === "RPC") await rpcFetch(verify); else await verify();
  }
  for (const length of [undefined, "1", String(limit + 50000)]) {
    Deno.test(`${name} UTF-8 byte overflow rejected with missing/lying length=${length}`, async () => {
      await isolated(async () => {
        // Valid JSON with semantic message under 2000 units, but UTF-8 padding above budget.
        const body = counted(JSON.stringify({ ...value, padding: "ế".repeat(limit / 2) }));
        let quota = 0;
        const response = await handle(req(body.stream, length), { consumeQuota: () => { quota++; return Promise.resolve(true); } });
        equal(response.status, 413);
        equal(quota, 0);
        equal(body.state.canceled, 1);
        equal(body.state.bytes <= limit + 1024, true);
        equal(body.state.bytes < body.total, true);
        equal(body.stream.locked, false);
        const data = await response.json();
        equal(name === "RPC" ? data.error : data.code, name === "RPC" ? "Request is too large." : "message_too_large");
      });
    });
  }
  for (const size of [limit, limit + 1]) {
    Deno.test(`${name} exact byte boundary ${size}`, async () => {
      await isolated(async () => {
        const body = counted(padded(value, size), 73);
        const response = await handle(req(body.stream, "1"));
        equal(response.status, size === limit ? 200 : 413);
        equal(body.stream.locked, false);
        equal(body.state.canceled, size === limit ? 0 : 1);
      });
    });
  }
  Deno.test(`${name} missing auth consumes zero caller bytes despite huge header`, async () => {
    const body = counted(padded(value, limit + 100));
    const response = await handle(req(body.stream, "99999999", ""));
    equal(response.status, 401);
    equal(body.state.bytes, 0);
    equal(body.stream.locked, false);
    await body.stream.cancel();
  });
  Deno.test(`${name} rejected auth consumes zero caller bytes`, async () => {
    const body = counted(padded(value, limit + 100));
    const verify = async () => {
      const response = await handle(req(body.stream), { authenticate: () => Promise.resolve(false) });
      equal(response.status, 401);
      equal(body.state.bytes, 0);
      equal(body.stream.locked, false);
      await body.stream.cancel();
    };
    if (name === "RPC") await rpcFetch(verify, false); else await verify();
  });
  Deno.test(`${name} malformed JSON remains sanitized 400`, async () => {
    await isolated(async () => {
      const body = counted('{"message":private', 2);
      const response = await handle(req(body.stream));
      equal(response.status, 400);
      equal((await response.text()).includes("private"), false);
      equal(body.stream.locked, false);
    });
  });
  Deno.test(`${name} under-limit VI/EN ignores overstated Content-Length`, async () => {
    await isolated(async () => {
      const body = counted(JSON.stringify(value), 1);
      equal((await handle(req(body.stream, "99999999"))).status, 200);
      equal(body.state.bytes, body.total);
      equal(body.stream.locked, false);
    });
  });
}

const providerValue = { choices: [{ message: { content: "Tập nhẹ. Train lightly." } }] };
for (const size of [262144, 262145, 280000]) {
  Deno.test(`Coach provider byte cap with short answer and padding ${size}`, async () => {
    const body = counted(padded(providerValue, size), 1000);
    let quota = 0;
    const response = await handleCoachRequest(new Request("https://local/coach", {
      method: "POST", headers: { Authorization: "Bearer valid" }, body: JSON.stringify({ message: "hi" }),
    }), deps({
      consumeQuota: () => { quota++; return Promise.resolve(true); },
      fetcher: () => Promise.resolve(new Response(body.stream, { headers: { "Content-Length": "1" } })),
    }));
    equal(response.status, size === 262144 ? 200 : 502);
    equal(quota, 1);
    equal(body.stream.locked, false);
    equal(body.state.canceled, size === 262144 ? 0 : 1);
    equal(body.state.bytes <= 263144, true);
    if (size === 262144) equal((await response.json()).answer, "Tập nhẹ. Train lightly.");
    else equal((await response.json()).code, "provider_unavailable");
  });
}
for (const status of [429, 500]) {
  Deno.test(`Coach non-ok provider ${status} cancels unread body`, async () => {
    const body = counted("private-provider-body".repeat(20000));
    const response = await handleCoachRequest(new Request("https://local/coach", {
      method: "POST", headers: { Authorization: "Bearer valid" }, body: '{"message":"hi"}',
    }), deps({ fetcher: () => Promise.resolve(new Response(body.stream, { status })) }));
    equal(response.status, status === 429 ? 429 : 502);
    equal(body.state.bytes, 0);
    equal(body.state.canceled, 1);
    equal(body.stream.locked, false);
    equal((await response.json()).code, "provider_unavailable");
  });
}

Deno.test("bounded decoder preserves split UTF-8 VI/EN and accepts empty body", async () => {
  const text = "Tập luyện đúng kỹ thuật. Train safely. 💪";
  const body = counted(text, 1);
  equal(await readBoundedText(body.stream, body.total), text);
  equal(body.stream.locked, false);
  equal(await readBoundedText(null, 16384), "");
});

Deno.test("bounded reader preserves original oversize error when cancel rejects and releases lock", async () => {
  const stream = new ReadableStream<Uint8Array>({
    pull(controller) { controller.enqueue(new Uint8Array(10)); },
    cancel() { throw new Error("private cancellation failure"); },
  }, { highWaterMark: 0 });
  let caught;
  try { await readBoundedText(stream, 1); } catch (error) { caught = error; }
  equal(caught instanceof BodyTooLargeError, true);
  equal(stream.locked, false);
});

Deno.test("bounded reader releases lock after stream read error", async () => {
  const stream = new ReadableStream<Uint8Array>({ pull(controller) { controller.error(new Error("read failure")); } });
  let caught;
  try { await readBoundedText(stream, 10); } catch (error) { caught = error; }
  equal(caught instanceof Error && caught.message, "read failure");
  equal(stream.locked, false);
});

Deno.test("Coach malformed provider JSON preserves sanitized 503", async () => {
  const body = counted("private-not-json", 1);
  const response = await handleCoachRequest(new Request("https://local/coach", {
    method: "POST", headers: { Authorization: "Bearer valid" }, body: '{"message":"hi"}',
  }), deps({ fetcher: () => Promise.resolve(new Response(body.stream)) }));
  equal(response.status, 503);
  equal((await response.json()).code, "coach_unavailable");
  equal(body.stream.locked, false);
});

Deno.test("Coach provider multibyte padding cannot bypass byte cap", async () => {
  const body = counted(JSON.stringify({ ...providerValue, padding: "ế".repeat(90000) }));
  const response = await handleCoachRequest(new Request("https://local/coach", {
    method: "POST", headers: { Authorization: "Bearer valid" }, body: '{"message":"hi"}',
  }), deps({ fetcher: () => Promise.resolve(new Response(body.stream)) }));
  equal(response.status, 502);
  equal(body.state.bytes < body.total, true);
  equal(body.state.canceled, 1);
  equal(body.stream.locked, false);
});

Deno.test("Coach preserves semantic limits and validation/quota/context/provider order", async () => {
  const events: string[] = [];
  const configured = deps({
    authenticate: () => { events.push("auth"); return Promise.resolve(true); },
    consumeQuota: () => { events.push("quota"); return Promise.resolve(true); },
    context: () => { events.push("context"); return Promise.resolve({}); },
    fetcher: () => { events.push("provider"); return Promise.resolve(Response.json(providerValue)); },
  });
  const send = (value: unknown, dependencies = configured) => handleCoachRequest(new Request("https://local/coach", {
    method: "POST", headers: { Authorization: "Bearer valid" }, body: JSON.stringify(value),
  }), dependencies);
  equal((await send({ message: "a".repeat(2001) })).status, 400);
  equal((await send({ message: "hi", history: [{ role: "user", content: "a".repeat(4001) }] })).status, 400);
  equal((await send({ message: "hi", history: Array(9).fill({ role: "user", content: "hi" }) })).status, 400);
  equal(events.join(","), "auth,auth,auth");
  events.length = 0;
  equal((await send({ message: "a".repeat(2000), history: [{ role: "user", content: "ế".repeat(4000) }] })).status, 200);
  equal(events.join(","), "auth,quota,context,provider");
  for (const length of [12000, 12001]) {
    const response = await send({ message: "hi" }, deps({ fetcher: () => Promise.resolve(Response.json({
      choices: [{ message: { content: "a".repeat(length) } }],
    })) }));
    equal(response.status, length === 12000 ? 200 : 502);
  }
});
