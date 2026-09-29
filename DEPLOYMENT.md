# Deploy Tradecraft: Vercel + Render + Supabase

These instructions deploy a personal/non-commercial educational beta. The source is prepared, but cloud accounts and a final hosted test are still needed. Do not upload the whole working folder: use the source ZIP or a repository excluding files in `.gitignore`.

## The three services

| Service | What runs there | Free-tier qualification/limit |
|---|---|---|
| Vercel Hobby | React dashboard | Personal/non-commercial use, within usage allowances |
| Render Free web service | Flask API + compiled Linux C++ library | Sleeps after inactivity; first request can take a while; usage limits apply |
| Supabase Free | PostgreSQL + user authentication | Database/auth quotas; low-activity projects can pause |

Vercel does not run our persistent native backend in this setup. Its static dashboard calls Render over HTTPS. Only Render receives the database password and any approved market-data keys.

Current provider references (checked September 28, 2026):
- https://vercel.com/docs/plans/hobby
- https://render.com/docs/free
- https://supabase.com/pricing
- https://supabase.com/docs/guides/platform/free-project-pausing

Free Render disks are not persistent, so the hosted app refuses SQLite. Do not select Render's temporary free PostgreSQL database for this plan; it expires after 30 days. Use Supabase PostgreSQL instead. A custom domain is optional; provider subdomains are sufficient for the website.

## 1. Put the source in a GitHub repository

Create a repository and upload the files from `tradecraft-source.zip`, with `package.json`, `Dockerfile`, and `render.yaml` at its root. Never upload `.env`, data files, credentials, `.venv`, or `node_modules`.

GitHub Actions will compile the C++ engine on Linux, run the database/authentication tests against PostgreSQL, build the frontend, and build the Docker image. Resolve any CI failure before deploying.

## 2. Set up Supabase

1. Create a Free project and keep its database password private.
2. Copy the project URL and **publishable** API key. These are the two public frontend settings; do not use a secret or service-role key in the frontend.
3. Under Authentication, use an asymmetric signing key (ES256 or RS256). This backend deliberately rejects legacy HS256 tokens. See https://supabase.com/docs/guides/auth/signing-keys.
4. Enable email/password sign-in and email confirmation. Configure a minimum password length of 12 characters in Supabase as well as the app.
5. For public email sign-up and recovery, configure custom SMTP. The default sender only delivers to project-team addresses and is not a general public email service. A free email-provider allowance may be sufficient, but its terms and domain-verification requirements are separate from hosting. See https://supabase.com/docs/guides/auth/auth-smtp. Do not disable confirmation merely to bypass this step.
6. Copy the PostgreSQL **session pooler** connection string from the Connect panel (IPv4-compatible, usually port 5432). Replace its password placeholder locally, URL-encoding special password characters, and include `sslmode=require`. Keep the resulting `DATABASE_URL` secret. See https://supabase.com/docs/guides/database/connecting-to-postgres.
7. Once the Vercel URL is known, set Supabase's Site URL and allowed redirect URL to that exact HTTPS URL. This is needed for confirmation and password recovery.

The backend creates `tc_accounts`, `tc_holdings`, `tc_trades`, and `tc_progress`. It enables row-level security and revokes direct access from anonymous and authenticated browser database roles. There are deliberately no browser database policies: all portfolio access goes through authenticated Flask routes. Use the database-owner connection for this first deployment so schema initialization and the private backend can access those tables. Keep that connection string only in Render's secret environment settings.

## 3. Create the Vercel frontend project

Import the GitHub repository. Choose Vite, build command `npm run build`, and output directory `dist`. Do not put Python or Alpaca secrets here. Reserve a stable production `.vercel.app` URL now; the initial site intentionally shows a configuration message until all settings are supplied.

Add these Vercel environment variables for the Production environment:

| Name | Value |
|---|---|
| `VITE_API_BASE_URL` | The Render backend HTTPS URL from step 4, without a trailing slash |
| `VITE_SUPABASE_URL` | Your Supabase project URL |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Supabase publishable key |

These values are embedded at build time. Redeploy after changing them. Frontend settings can be public; database passwords and market-data secret keys must never start with `VITE_`.

## 4. Create the Render backend

Import `render.yaml` as a Blueprint, or create a Web Service from the repo with Docker runtime and the Free plan. Do not add paid disks/databases. The Dockerfile compiles C++ for Linux, installs the Python runtime, and starts Gunicorn as an unprivileged user.

Set:

| Name | Value |
|---|---|
| `PUBLIC_DEPLOYMENT` | `true` |
| `MARKET_MODE` | `demo` |
| `DATABASE_URL` | Secret Supabase pooler connection string with TLS |
| `SUPABASE_URL` | Same project URL as Vercel |
| `ALLOWED_ORIGINS` | Exact production Vercel URL, e.g. `https://your-project.vercel.app` |

Use `/api/health` as the health-check path. It should return `status: ok` and `authentication: required`. `/api/state` without a bearer token must return 401. Copy the Render URL into Vercel's `VITE_API_BASE_URL`, then redeploy the frontend.

`ALLOWED_ORIGINS` accepts a comma-separated list of explicit HTTPS origins. No wildcards. Preview URLs must be added individually if you want them to access this backend. The bundled content-security policy allows the normal `*.supabase.co` and `*.onrender.com` endpoints; update it for custom backend/auth domains.

## 5. Check the actual hosted site before sharing

- Register with an address outside your Supabase team; receive the confirmation email and confirm.
- Sign in, place a virtual buy and sell, and check the saved journal.
- Complete a quiz; reload and check that completion persists.
- Sign out. Use a second account and verify that it starts with $10,000 and cannot see the first account's holdings or notes.
- Test password reset and sign in with the new password.
- Wait for the backend to sleep and check that the loading/retry experience recovers.
- Confirm the UI says generated demo prices and no real orders are possible.
- Check provider quotas and billing settings; avoid paid upgrades unless intentionally chosen.

Do not claim public email sign-up, cloud database storage, or hosted operation is verified until these checks pass. Supabase's SMTP setup and actual cloud credentials cannot be tested from an unconfigured local project.

## Live data later

Keep the existing local live launcher for personal testing. Public redistribution needs separate confirmation from the market-data provider. Once your agreement permits the intended display, add `ALPACA_API_KEY` and `ALPACA_SECRET_KEY` only in Render, set `MARKET_MODE=alpaca` and `PUBLIC_MARKET_DATA_LICENSED=true`, and redeploy. The switch is an acknowledgement, not a license. Never assume that a working personal key grants public display rights.

Demo and live accounts are stored separately. Supabase sign-in identifies users; nobody needs your Alpaca keys.

## Operations and ownership

The free configuration is for a small beta. Keep regular encrypted database exports in a private location; free-tier backups/retention are limited. Delete a user's application records by their Supabase user UUID from the four `tc_` tables before deleting their Auth account when handling a deletion request. Do not delete by email alone. Add an owner contact and a suitable privacy notice before inviting the public; the app itself states what account data it stores. Never request real financial details in journal entries.

Keep dependency/security updates current. The per-account write limiter is in memory and assumes one Gunicorn process. Larger deployments need shared rate limiting, monitoring, and a reviewed migration/backup strategy. Provider terms, limits, and prices can change; recheck before launch.
