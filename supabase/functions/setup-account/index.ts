
import { withSupabase } from "npm:@supabase/server@1";

const json = (body: unknown, status = 200) =>
  Response.json(body, {
    status,
    headers: { "Content-Type": "application/json" },
  });

export default {
  // Public client call uses the publishable key.
  // The privileged client is only inside this Edge Function.
  fetch: withSupabase({ auth: "publishable" }, async (req, ctx) => {
    if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

    try {
      const body = await req.json();

      const schoolAccessCode = String(body.school_access_code ?? "").trim();
      const accountType = String(body.account_type ?? "").trim();
      const identifier = String(body.identifier ?? "").trim();
      const password = String(body.password ?? "");

      if (!schoolAccessCode || !accountType || !identifier || password.length < 8) {
        return json({ error: "Invalid setup data." }, 400);
      }

      const { data: rows, error: lookupError } =
        await ctx.supabaseAdmin.rpc("find_login_account", {
          p_school_access_code: schoolAccessCode,
          p_account_type: accountType,
          p_identifier: identifier,
        });

      if (lookupError || !rows || rows.length !== 1) {
        return json({ error: "Account could not be verified." }, 400);
      }

      const account = rows[0];

      if (account.already_activated) {
        return json({ error: "Account is already activated." }, 409);
      }

      const { data: created, error: createError } =
        await ctx.supabaseAdmin.auth.admin.createUser({
          email: account.auth_login_email,
          password,
          email_confirm: true,
          user_metadata: {
            school_id: account.school_id,
            public_user_id: account.user_id,
            role: account.role,
          },
        });

      if (createError || !created.user) {
        return json({ error: createError?.message ?? "Auth creation failed." }, 400);
      }

      const { error: linkError } = await ctx.supabaseAdmin
        .from("users")
        .update({ auth_user_id: created.user.id })
        .eq("id", account.user_id)
        .is("auth_user_id", null);

      if (linkError) {
        await ctx.supabaseAdmin.auth.admin.deleteUser(created.user.id);
        return json({ error: "Could not link Auth account." }, 500);
      }

      return json({
        ok: true,
        auth_login_email: account.auth_login_email,
        display_name: account.display_name,
      });
    } catch (_) {
      return json({ error: "Invalid request." }, 400);
    }
  }),
};
