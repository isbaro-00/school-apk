
import { withSupabase } from "npm:@supabase/server@1";

const json = (body: unknown, status = 200) =>
  Response.json(body, {
    status,
    headers: { "Content-Type": "application/json" },
  });

export default {
  fetch: withSupabase({ auth: "publishable" }, async (req, ctx) => {
    if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

    try {
      const body = await req.json();

      const schoolAccessCode = String(body.school_access_code ?? "").trim();
      const accountType = String(body.account_type ?? "").trim();
      const identifier = String(body.identifier ?? "").trim();

      if (!schoolAccessCode || !accountType || !identifier) {
        return json({ error: "Invalid login data." }, 400);
      }

      const { data: rows, error } = await ctx.supabaseAdmin.rpc(
        "find_login_account",
        {
          p_school_access_code: schoolAccessCode,
          p_account_type: accountType,
          p_identifier: identifier,
        },
      );

      if (error || !rows || rows.length !== 1) {
        return json({ error: "Account could not be verified." }, 400);
      }

      const account = rows[0];

      if (!account.already_activated) {
        return json({
          activated: false,
          needs_setup: true,
          display_name: account.display_name,
        });
      }

      return json({
        activated: true,
        auth_login_email: account.auth_login_email,
        display_name: account.display_name,
      });
    } catch (_) {
      return json({ error: "Invalid request." }, 400);
    }
  }),
};
