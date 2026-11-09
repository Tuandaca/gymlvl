import { handleDeleteAccount, type DeleteAccountDeps } from "./index.ts";

const request = (method = "POST", token?: string) =>
  new Request("https://local/delete-account", {
    method,
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });

function equal(actual: unknown, expected: unknown, msg = "") {
  if (actual !== expected) throw new Error(`${msg} Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
}

function deps(overrides: Partial<DeleteAccountDeps> = {}): any {
  let rpcUid: string | null = null;
  let rpcCalls = 0;
  let adminCalls = 0;
  let adminError: unknown = null;
  return {
    authenticate: overrides.authenticate ?? (async (token) => (token === "valid" ? "uid-owner-a" : null)),
    envGet: overrides.envGet ?? ((key) => {
      if (key === "SUPABASE_URL") return "http://127.0.0.1:54321";
      if (key === "SUPABASE_ANON_KEY" || key === "SUPABASE_PUBLISHABLE_KEY")
        return "sb_publishable_test";
      if (key === "SUPABASE_SERVICE_ROLE_KEY") return "sb_secret_test";
      return undefined;
    }),
    rpcDeleteAccount: overrides.rpcDeleteAccount ?? (async (uid) => { rpcUid = uid; rpcCalls++; return { error: null }; }),
    adminDeleteUser: overrides.adminDeleteUser ?? (async (_uid) => { adminCalls++; return { error: adminError }; }),
    // Test-only inspectors.
    get rpcUid() { return rpcUid; },
    get rpcCallCount() { return rpcCalls; },
    get adminCallCount() { return adminCalls; },
    setAdminError(e: unknown) { adminError = e; },
  } as unknown as DeleteAccountDeps & {
    rpcUid: string | null;
    rpcCallCount: number;
    adminCallCount: number;
    setAdminError: (e: unknown) => void;
  };
}

Deno.test("delete-account: unauthenticated request is denied", async () => {
  const d = deps();
  const res = await handleDeleteAccount(request("POST", ""), d);
  equal(res.status, 401);
  const body = await res.json();
  equal(body.code, "unauthorized");
  equal(d.rpcCallCount, 0);
  equal(d.adminCallCount, 0);
});

Deno.test("delete-account: invalid method is denied", async () => {
  const d = deps({ authenticate: () => Promise.resolve("uid-owner-a") }) as any;
  const res = await handleDeleteAccount(request("GET", "valid"), d);
  equal(res.status, 405);
  equal(d.rpcCallCount, 0);
});

Deno.test("delete-account: OPTIONS preflight is allowed", async () => {
  const d = deps() as any;
  const res = await handleDeleteAccount(new Request("https://local/delete-account", { method: "OPTIONS" }), d);
  equal(res.status, 200);
});

Deno.test("delete-account: invalid bearer token is denied", async () => {
  const d = deps() as any;
  const res = await handleDeleteAccount(request("POST", "invalid-token"), d);
  equal(res.status, 401);
  equal(d.rpcCallCount, 0);
});

Deno.test("delete-account: authenticated user deletes only self", async () => {
  const d = deps() as any;
  const res = await handleDeleteAccount(request("POST", "valid"), d);
  equal(res.status, 200);
  const body = await res.json();
  equal(body.code, "account_deleted");
  equal(d.rpcUid, "uid-owner-a");
  equal(d.rpcCallCount, 1);
  equal(d.adminCallCount, 1);
});

Deno.test("delete-account: client cannot choose an arbitrary victim user id", async () => {
  const d = deps({ authenticate: () => Promise.resolve("uid-owner-a") }) as any;
  const res = await handleDeleteAccount(
    new Request("https://local/delete-account", {
      method: "POST",
      headers: { Authorization: "Bearer valid" },
      body: JSON.stringify({ target_user_id: "uid-victim-b" }),
    }),
    d,
  );
  equal(res.status, 200);
  equal(d.rpcUid, "uid-owner-a");
  equal(d.rpcUid !== "uid-victim-b", true);
});

Deno.test("delete-account: RPC failure returns sanitized failure", async () => {
  const d = deps({
    authenticate: () => Promise.resolve("uid-owner-a"),
    rpcDeleteAccount: async () => ({ error: new Error("rpc down") }),
  }) as any;
  const res = await handleDeleteAccount(request("POST", "valid"), d);
  equal(res.status, 500);
  const body = await res.json();
  equal(body.code, "deletion_failed");
  equal(d.adminCallCount, 0);
});

Deno.test("delete-account: admin deletion failure returns 202 advisory", async () => {
  const d = deps({
    authenticate: () => Promise.resolve("uid-owner-a"),
    adminDeleteUser: async () => ({ error: new Error("auth delete failed") }),
  }) as any;
  const res = await handleDeleteAccount(request("POST", "valid"), d);
  equal(res.status, 202);
  const body = await res.json();
  equal(body.code, "auth_row_removal_deferred");
});

Deno.test("delete-account: missing service-role key returns 202 advisory", async () => {
  const d = deps({
    authenticate: () => Promise.resolve("uid-owner-a"),
    envGet: (key) => (key === "SUPABASE_SERVICE_ROLE_KEY" ? undefined : "http://127.0.0.1:54321"),
  }) as any;
  const res = await handleDeleteAccount(request("POST", "valid"), d);
  equal(res.status, 202);
  const body = await res.json();
  equal(body.code, "auth_row_removal_deferred");
});

Deno.test("delete-account: retry is idempotent after partial failure", async () => {
  const d = deps({
    authenticate: () => Promise.resolve("uid-owner-a"),
    adminDeleteUser: async () => ({ error: new Error("transient") }),
  }) as any;
  const first = await handleDeleteAccount(request("POST", "valid"), d);
  equal(first.status, 202);
  const second = await handleDeleteAccount(request("POST", "valid"), d);
  equal(second.status, 202);
});

Deno.test("delete-account: service-role credential is never returned to client", async () => {
  const d = deps({
    authenticate: () => Promise.resolve("uid-owner-a"),
    envGet: (key) =>
      key === "SUPABASE_SERVICE_ROLE_KEY" ? "sb_secret_test" : "http://127.0.0.1:54321",
  }) as any;
  const res = await handleDeleteAccount(request("POST", "valid"), d);
  equal(res.status, 200);
  const text = await res.text();
  equal(text.includes("sb_secret_test"), false);
  equal(text.includes("service_role"), false);
});
