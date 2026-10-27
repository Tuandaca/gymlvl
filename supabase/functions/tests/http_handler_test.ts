import { rpcHandler } from "../_shared/http.ts";

function equal(actual: unknown, expected: unknown) {
  if (actual !== expected) throw new Error(`Expected ${expected}, got ${actual}`);
}

async function isolatedFetch(
  fetcher: typeof fetch,
  verify: () => Promise<void>,
) {
  const originalFetch = globalThis.fetch;
  const originalUrl = Deno.env.get("SUPABASE_URL");
  const originalKey = Deno.env.get("SUPABASE_ANON_KEY");
  Deno.env.set("SUPABASE_URL", "https://backend.example.test");
  Deno.env.set("SUPABASE_ANON_KEY", "test-public-key");
  globalThis.fetch = fetcher;
  try {
    await verify();
  } finally {
    globalThis.fetch = originalFetch;
    if (originalUrl === undefined) Deno.env.delete("SUPABASE_URL");
    else Deno.env.set("SUPABASE_URL", originalUrl);
    if (originalKey === undefined) Deno.env.delete("SUPABASE_ANON_KEY");
    else Deno.env.set("SUPABASE_ANON_KEY", originalKey);
  }
}

const request = (body = "{}", token = "test-user-token", method = "POST") =>
  new Request("https://functions.example.test/calculate-xp", {
    method,
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    ...(method === "POST" ? { body } : {}),
  });

const user = {
  id: "11111111-1111-4111-8111-111111111111",
  aud: "authenticated",
  role: "authenticated",
  email: "athlete@example.test",
};

Deno.test("RPC handler rejects unauthenticated requests before database access", async () => {
  await isolatedFetch(() => Promise.reject(new Error("Unexpected network access")), async () => {
    const handler = rpcHandler("start_workout");
    equal((await handler(request("{}", ""))).status, 401);
    equal((await handler(request("{}", "", "GET"))).status, 405);
    const cors = await handler(request("{}", "", "OPTIONS"));
    equal(cors.status, 200);
    equal(cors.headers.get("Access-Control-Allow-Methods"), "POST, OPTIONS");
  });
});

Deno.test("RPC handler rejects expired or invalid tokens with a sanitized 401", async () => {
  let calls = 0;
  await isolatedFetch(() => {
    calls++;
    return Promise.resolve(Response.json({ message: "JWT expired; internal details" }, { status: 401 }));
  }, async () => {
    const response = await rpcHandler("start_workout")(request());
    equal(response.status, 401);
    equal(calls, 1);
    equal((await response.json()).error, "Your session expired. Please sign in again.");
  });
});

Deno.test("RPC handler verifies user and forwards the same access token to PostgreSQL", async () => {
  const paths: string[] = [];
  await isolatedFetch((input, init) => {
    const url = input instanceof Request ? input.url : String(input);
    paths.push(new URL(url).pathname);
    equal(new Headers(init?.headers).get("Authorization"), "Bearer test-user-token");
    if (url.endsWith("/auth/v1/user")) return Promise.resolve(Response.json(user));
    equal(url.endsWith("/rest/v1/rpc/complete_workout"), true);
    equal(JSON.parse(String(init?.body)).p_workout_id, user.id);
    return Promise.resolve(Response.json({ earnedXP: 10 }));
  }, async () => {
    const response = await rpcHandler("complete_workout", body => ({ p_workout_id: body.workout_id }))(
      request(JSON.stringify({ workout_id: user.id, earnedXP: 999999 })),
    );
    equal(response.status, 200);
    equal((await response.json()).earnedXP, 10);
    equal(paths.join(","), "/auth/v1/user,/rest/v1/rpc/complete_workout");
  });
});

Deno.test("RPC handler validates JSON shape and size before calling the database", async () => {
  await isolatedFetch(input => {
    const url = input instanceof Request ? input.url : String(input);
    equal(url.endsWith("/auth/v1/user"), true);
    return Promise.resolve(Response.json(user));
  }, async () => {
    const handler = rpcHandler("start_workout");
    equal((await handler(request("not-json"))).status, 400);
    equal((await handler(request("[]"))).status, 400);
    equal((await handler(request("null"))).status, 400);
    equal((await handler(request("a".repeat(16385)))).status, 413);
  });
});

Deno.test("RPC handler sanitizes database errors without leaking internal messages", async () => {
  await isolatedFetch(input => {
    const url = input instanceof Request ? input.url : String(input);
    return Promise.resolve(url.endsWith("/auth/v1/user")
      ? Response.json(user)
      : Response.json({ code: "42501", message: "private internal table details" }, { status: 403 }));
  }, async () => {
    const response = await rpcHandler("start_workout")(request());
    equal(response.status, 403);
    equal((await response.text()).includes("private internal"), false);
  });
});
