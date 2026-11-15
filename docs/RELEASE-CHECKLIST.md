# ASPHYR — Release checklist

How to do the before-release steps yourself. Why each one exists is in `BACKEND-SPEC.md`, Before release. Do them in this order, right before inviting friends to TestFlight, not earlier.

## 1. Let anyone sign in with Google
While Google's consent screen is in **Testing**, only the people listed as test users can sign in.
1. Go to [console.cloud.google.com](https://console.cloud.google.com) and pick the project you made for ASPHYR's Google sign-in.
2. Open **Google Auth Platform** (older name: **OAuth consent screen**) → **Audience**.
3. Under **Publishing status**, click **Publish app**, then confirm.
4. ASPHYR only asks for the basic email and profile, so Google publishes it without a review.
5. Check: sign in with a Google account that isn't on the test user list.

## 2. Use the real minimum quest time
The server lets a quest finish after 1% of its time, which was set to make testing quick. The real rule is 50%.
1. In [supabase.com](https://supabase.com/dashboard), open the **ASPHYR** organization, then the ASPHYR project. Never the project called Synapse.
2. Open **SQL Editor**, then **New query**.
3. Paste this and click **Run**:
   ```sql
   update private.settings set minimum_time_fraction = 0.5;
   ```
4. Check it with:
   ```sql
   select minimum_time_fraction from private.settings;
   ```
   It should show `0.5`. To go back to quick testing, run the update again with `0.01`.

## 3. Delete the test accounts
Do this last, so your own testing isn't interrupted.
1. In the ASPHYR project, open **Authentication** → **Users**.
2. For each test account: the **⋯** menu → **Delete user**. Keep your own real account if you want it.
3. Or, signed in as that account in the app: **Settings** → **Delete Account**, which also removes its photo.
4. Check **Table Editor** → **profiles**: only accounts you kept should be left.

## 4. Privacy policy
App Store Connect may ask for a privacy policy link before outside testers can join. It's checked in the TestFlight step. Claude can draft one for you to edit and host, for example as a free GitHub Pages page.

## Later, before the public App Store release
- **Custom email:** sign up for an email service (Resend or Brevo), add its SMTP details in Supabase under **Authentication** → **Emails** → **SMTP Settings**, then raise the limit in **Authentication** → **Rate Limits**. Owning a domain (about $10 a year) helps emails avoid spam.
- **Email confirmation on:** **Authentication** → **Sign In / Providers** → **Email** → **Confirm email**. The app needs a "check your email" screen first, which Claude will build.
- **Leaked password protection:** **Authentication** → **Password security**, on Supabase's Pro plan only.
