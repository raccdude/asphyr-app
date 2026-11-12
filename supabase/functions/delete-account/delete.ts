// Deletes the signed-in user's account: their photo, then their login. Deleting the
// login removes every row of theirs, as each table cascades from auth.users.
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

/// The parts of an admin client this uses, so tests can pass a fake one.
export type AdminClient = Pick<SupabaseClient, "auth" | "storage">;

const photoBucket = "avatars";

function reply(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export async function deleteAccount(request: Request, admin: AdminClient): Promise<Response> {
  if (request.method !== "POST") {
    return reply(405, { error: "method_not_allowed" });
  }

  // The user is checked here as well as by the platform, so this never relies on
  // the platform's setting alone
  const token = request.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!token) {
    return reply(401, { error: "not_signed_in" });
  }

  const { data: userData, error: userError } = await admin.auth.getUser(token);
  const userID = userData?.user?.id;
  if (userError || !userID) {
    return reply(401, { error: "not_signed_in" });
  }

  // Storage files don't cascade, so the photo goes first. If this fails, the login
  // stays, and the user can try again.
  const photos = admin.storage.from(photoBucket);
  const { data: files, error: listError } = await photos.list(userID);
  if (listError) {
    return reply(500, { error: "photo_not_deleted" });
  }
  if (files && files.length > 0) {
    const { error: removeError } = await photos.remove(files.map((file) => `${userID}/${file.name}`));
    if (removeError) {
      return reply(500, { error: "photo_not_deleted" });
    }
  }

  const { error: deleteError } = await admin.auth.admin.deleteUser(userID);
  if (deleteError) {
    return reply(500, { error: "account_not_deleted" });
  }

  return reply(200, { deleted: true });
}
