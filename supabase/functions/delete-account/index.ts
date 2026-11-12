// Delete Account. Removing a login needs a secret key, which can't be in the app.
// Called by AccountService.deleteAccount with the user's session.
import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteAccount } from "./delete.ts";

/// Supabase provides these. The new secret keys come as JSON keyed by name, and the
/// older service role key is used if they're missing.
function secretKey(): string {
  const keys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (keys) {
    const key = JSON.parse(keys)["default"];
    if (key) return key;
  }
  return Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
}

const admin = createClient(Deno.env.get("SUPABASE_URL") ?? "", secretKey(), {
  auth: { persistSession: false, autoRefreshToken: false },
});

Deno.serve((request) => deleteAccount(request, admin));
