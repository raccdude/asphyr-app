// Run with: zsh scripts/db-tests/run.sh, or `deno test --allow-env` in supabase/functions
import { assertEquals } from "jsr:@std/assert@1";
import { type AdminClient, deleteAccount } from "./delete.ts";

type Calls = string[];

function fakeAdmin(calls: Calls, options: {
  userID?: string;
  files?: string[];
  listFails?: boolean;
  removeFails?: boolean;
  deleteFails?: boolean;
} = {}): AdminClient {
  const fake = {
    auth: {
      getUser: (token: string) => {
        calls.push(`getUser ${token}`);
        return Promise.resolve(options.userID
          ? { data: { user: { id: options.userID } }, error: null }
          : { data: { user: null }, error: { message: "bad token" } });
      },
      admin: {
        deleteUser: (id: string) => {
          calls.push(`deleteUser ${id}`);
          return Promise.resolve({ data: {}, error: options.deleteFails ? { message: "no" } : null });
        },
      },
    },
    storage: {
      from: (bucket: string) => ({
        list: (path: string) => {
          calls.push(`list ${bucket}/${path}`);
          return Promise.resolve(options.listFails
            ? { data: null, error: { message: "no" } }
            : { data: (options.files ?? []).map((name) => ({ name })), error: null });
        },
        remove: (paths: string[]) => {
          calls.push(`remove ${paths.join(",")}`);
          return Promise.resolve({ data: [], error: options.removeFails ? { message: "no" } : null });
        },
      }),
    },
  };
  return fake as unknown as AdminClient;
}

function post(token?: string): Request {
  return new Request("http://localhost/delete-account", {
    method: "POST",
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
}

Deno.test("deletes the photo, then the login", async () => {
  const calls: Calls = [];
  const response = await deleteAccount(post("jwt"), fakeAdmin(calls, { userID: "u1", files: ["avatar.jpg"] }));
  assertEquals(response.status, 200);
  assertEquals(calls, ["getUser jwt", "list avatars/u1", "remove u1/avatar.jpg", "deleteUser u1"]);
});

Deno.test("an account with no photo is still deleted", async () => {
  const calls: Calls = [];
  const response = await deleteAccount(post("jwt"), fakeAdmin(calls, { userID: "u1" }));
  assertEquals(response.status, 200);
  assertEquals(calls, ["getUser jwt", "list avatars/u1", "deleteUser u1"]);
});

Deno.test("a request with no session is refused", async () => {
  const calls: Calls = [];
  const response = await deleteAccount(post(), fakeAdmin(calls, { userID: "u1" }));
  assertEquals(response.status, 401);
  assertEquals(calls, []);
});

Deno.test("a session that doesn't check out is refused, and nothing is deleted", async () => {
  const calls: Calls = [];
  const response = await deleteAccount(post("forged"), fakeAdmin(calls));
  assertEquals(response.status, 401);
  assertEquals(calls, ["getUser forged"]);
});

Deno.test("only the caller's own account is deleted", async () => {
  const calls: Calls = [];
  await deleteAccount(post("jwt"), fakeAdmin(calls, { userID: "me", files: ["avatar.jpg"] }));
  assertEquals(calls.filter((call) => call.includes("other")), []);
  assertEquals(calls.at(-1), "deleteUser me");
});

Deno.test("if the photo can't be removed, the login stays so it can be tried again", async () => {
  for (const failure of [{ listFails: true }, { removeFails: true }]) {
    const calls: Calls = [];
    const response = await deleteAccount(
      post("jwt"),
      fakeAdmin(calls, { userID: "u1", files: ["avatar.jpg"], ...failure }),
    );
    assertEquals(response.status, 500);
    assertEquals(calls.some((call) => call.startsWith("deleteUser")), false);
  }
});

Deno.test("a failed login deletion is reported", async () => {
  const response = await deleteAccount(post("jwt"), fakeAdmin([], { userID: "u1", deleteFails: true }));
  assertEquals(response.status, 500);
  assertEquals(await response.json(), { error: "account_not_deleted" });
});

Deno.test("only POST is accepted", async () => {
  const calls: Calls = [];
  const response = await deleteAccount(new Request("http://localhost/", { method: "GET" }), fakeAdmin(calls));
  assertEquals(response.status, 405);
  assertEquals(calls, []);
});
