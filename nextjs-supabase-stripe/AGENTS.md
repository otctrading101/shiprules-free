# Project instructions: Next.js + Supabase + Stripe (ShipRules free starter)

## Supabase auth & RLS
- Every table in `public` gets `alter table ... enable row level security;` in the SAME migration that creates it, plus explicit policies. No table ships without RLS.
- **Data API grants (required from Oct 30, 2026 on existing projects; already default on new projects):** new tables in `public` are NOT exposed to the Data API (`supabase-js` / PostgREST) until you `GRANT` privileges. Missing grants return Postgres error `42501` ("permission denied for table …"). In the same migration as `CREATE TABLE` + RLS:
  - Grant least privilege: e.g. `GRANT SELECT, INSERT, UPDATE, DELETE ON public.your_table TO authenticated;`
  - Grant to `anon` ONLY when the table is truly public, and only the verbs you need (usually `SELECT`); never `GRANT ALL` to `anon`.
  - Grant to `service_role` only for tables server/webhook code must write (still keep RLS on; service_role bypasses RLS).
  - Do not rely on default privileges; make grants explicit and reviewable in migrations.
- Policies use `(select auth.uid())` and scope by owner column, e.g. `using ((select auth.uid()) = user_id)`. Add `with check` on insert/update.
- Never write `using (true)` on writable tables. Public read tables must be read-only (`for select`).
- Users must not be able to update billing columns (plan, stripe_customer_id, subscription_status). Put these in a separate table only writable by the service role (webhook).
- On the server, use `supabase.auth.getUser()` (verifies with Auth server) for authorization; do not trust `getSession()` data alone.
- Service role key (`SUPABASE_SERVICE_ROLE_KEY`) is server-only: only in `lib/supabase/admin.ts` with `import "server-only"`. Never `NEXT_PUBLIC_`. Use it only for webhooks/admin jobs, and still filter by user id.
- Check authorization in every Server Action and route handler, not only in middleware or the UI.
- Storage buckets: private by default, with RLS policies on `storage.objects`.

## Stripe webhooks
- The success/redirect page NEVER grants access. Only the verified webhook updates plan or entitlement.
- Webhook route (`app/api/stripe/webhook/route.ts`): `export const runtime = "nodejs"`; read the raw body with `await req.text()`. Never call `req.json()` before verification: signatures are computed over the exact raw bytes.
- Verify with `stripe.webhooks.constructEvent(body, req.headers.get("stripe-signature")!, process.env.STRIPE_WEBHOOK_SECRET!)`.
- Fail closed: on a verification error return 400. Never catch-and-continue, log-and-continue, or skip verification "in dev".
- Idempotency: Stripe retries, so the same event can arrive more than once. Record `event.id` (unique constraint) before side effects; if it already exists, return 200 and skip.

## Env & secrets
- Only values safe for the public get `NEXT_PUBLIC_`: Supabase URL, anon/publishable key, Stripe publishable key, site URL. Everything else is server-only.
- Never hardcode keys (`sk_live_`, `sk_test_`, `whsec_`, service-role JWTs) in code, tests, or docs. Read from `process.env` via `lib/env.ts` (Zod-validated, fails fast at boot).
- `.env*.local` is gitignored; commit only `.env.example` with placeholder values.
- Do not log env values, tokens, or full request headers.
- If a secret was ever committed, tell the user to rotate it; deleting the line is not enough.

---
Free ShipRules starter rules (MIT). Full pack with more rules, a scanner, hooks and a checklist: https://shiprules.gumroad.com/l/lztkjm
