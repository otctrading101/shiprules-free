# ShipRules Free: rules that stop AI coding agents shipping the bugs they always ship

**Your agent writes `USING (true)` RLS policies, parses Stripe webhooks with `req.json()` so the signature check can never work, and puts Godot 3 `yield` in your Godot 4 game. These drop-in rules tell it not to.**

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/otctrading101/shiprules-free?style=social)](https://github.com/otctrading101/shiprules-free/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/otctrading101/shiprules-free)](https://github.com/otctrading101/shiprules-free/commits)
![Cursor](https://img.shields.io/badge/Cursor-.mdc-black)
![Claude Code](https://img.shields.io/badge/Claude_Code-CLAUDE.md-d97757)
![Codex / Windsurf / Copilot](https://img.shields.io/badge/Codex_%7C_Windsurf_%7C_Copilot-AGENTS.md-blue)

Plain Markdown rules, no install, no dependencies, MIT. Copy one folder into your project and your agent picks it up.

| Stack | Mistakes the rules forbid | Folder |
|---|---|---|
| **Next.js + Supabase + Stripe** | Tables with no **Row Level Security**, `using (true)` on writable tables, `service_role` key in client code or `NEXT_PUBLIC_`, missing Data API `GRANT`s (error `42501`), Stripe webhooks parsed with `req.json()` before `constructEvent`, catch-and-continue on bad signatures, no `event.id` idempotency, hardcoded `sk_live_` / `whsec_` keys | [`nextjs-supabase-stripe/`](nextjs-supabase-stripe) (3 rules) |
| **Godot 4** | **Godot 3 code** in Godot 4 projects: `yield`, `export var`, `onready`, `setget`, `connect("sig", self, "m")`, `puppet`/`remote` RPCs, `PoolStringArray`. Plus the Godot 3 habits that still compile and misbehave: missing `super()` in `_ready()`, exclusive `slice()`, inverted `Camera2D.zoom` | [`godot4/`](godot4) (3 rules + `scripts/check-godot3.sh`) |
| **Unity 6** | Obsolete APIs (`FindObjectOfType`, `rb.velocity`, `drag`), `?.` / `??` on Unity objects, unchecked `[SerializeField]` refs | [`unity6/`](unity6) (2 rules) |
| **discord.js v14** | "The application did not respond" (missed 3-second `deferReply`), `rest.put` on every startup, hardcoded bot tokens, `@everyone` pings from echoed user text | [`discordjs-v14/`](discordjs-v14) (2 rules) |

## Before / after

**Prompt:** "Add a Stripe webhook that marks the user as paid."

What agents commonly write. Anyone who finds the URL can POST a fake event and unlock paid features:

```ts
// app/api/stripe/webhook/route.ts  ❌
export async function POST(req: Request) {
  const event = await req.json();                 // parsed: signature can never be verified
  if (event.type === "checkout.session.completed") await markPaid(event.data.object.customer);
  return Response.json({ received: true });
}
```

What [`30-stripe-webhooks.mdc`](nextjs-supabase-stripe/.cursor/rules/30-stripe-webhooks.mdc) tells the agent to write instead:

```ts
// ✅ raw body, verify first, fail closed, dedupe retries
export const runtime = "nodejs";
export async function POST(req: Request) {
  const body = await req.text();
  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, req.headers.get("stripe-signature")!, process.env.STRIPE_WEBHOOK_SECRET!);
  } catch {
    return new Response("Invalid signature", { status: 400 });
  }
  if (!(await recordEventOnce(event.id))) return Response.json({ received: true });
  if (event.type === "checkout.session.completed") await markPaid(/* ... */);
  return Response.json({ received: true });
}
```

Same idea for Supabase (excerpt from [`20-supabase-security.mdc`](nextjs-supabase-stripe/.cursor/rules/20-supabase-security.mdc)):

```sql
-- ❌ what agents write to "fix" an RLS error
create policy "anyone" on profiles for all using (true);

-- ✅ what the rule requires
alter table profiles enable row level security;
create policy "own row" on profiles for select using ((select auth.uid()) = id);
```

And Godot 4 (from [`10-gdscript2-syntax.mdc`](godot4/.cursor/rules/10-gdscript2-syntax.mdc)): `yield(get_tree().create_timer(1), "timeout")` becomes `await get_tree().create_timer(1.0).timeout`, `export var speed = 5` becomes `@export var speed: float = 5.0`.

Godot 4 projects also get [`scripts/check-godot3.sh`](godot4/scripts/check-godot3.sh), a zero-dependency check that exits 1 if any `.gd` file contains Godot 3 syntax. Run it in CI or as a Claude Code Stop hook:

```bash
bash scripts/check-godot3.sh .   # prints offending lines, exit 1 on Godot 3 syntax
```

## Install (30 seconds)

```bash
git clone --depth 1 https://github.com/otctrading101/shiprules-free
cp -Rn shiprules-free/godot4/. my-godot-game/   # or nextjs-supabase-stripe/, unity6/, discordjs-v14/
```

`-n` never overwrites your files. If you already have an `AGENTS.md` or `CLAUDE.md`, paste our sections into yours.

Each folder has the same rules in three formats:

| Tool | File it reads | Notes |
|---|---|---|
| **Cursor** | `.cursor/rules/*.mdc` | Current format with `description` / `globs` / `alwaysApply`, so each rule only loads for matching files. Check under Settings → Rules. |
| **Claude Code** | `CLAUDE.md` | Imports `AGENTS.md` with `@AGENTS.md`. Run `/context` to confirm it loaded. |
| **OpenAI Codex** | `AGENTS.md` | Read automatically from the repo root. |
| **Windsurf** | `AGENTS.md` | A root `AGENTS.md` is treated as an always-on rule. |
| **GitHub Copilot agent, Gemini CLI, Zed, Aider** | `AGENTS.md` | Any tool that follows [agents.md](https://agents.md). |

## Sources

Rules were checked against the official docs: Cursor Rules, Claude Code memory, agents.md, Windsurf AGENTS.md, Supabase RLS and Data API grants, Stripe webhook signature verification, the Unity 6 Scripting API, Godot's "Upgrading from Godot 3 to Godot 4" guide and its `renames_map_3_to_4.cpp`, the discord.js v14 guide, and the Discord Gateway docs.

Rules guide your agent; they don't guarantee its output. Always review security-critical code.

## Contributing

Caught your agent making a mistake these rules miss? Open an issue with the bad code, or a PR with a rule plus a link to the official doc it's based on.

⭐ **Star the repo if it saved you a bug.** It helps other people find it.

## Want the full packs?

The free set is 2–3 rules per stack (plus the Godot 3 syntax check). The paid ShipRules packs (one-time purchase) add the full rule set (6–7 rules per stack), Copilot instructions, a zero-dependency scanner (leaked keys, missing RLS, unverified webhooks, Godot 3 syntax, obsolete Unity APIs, discord.js v13 code), Claude Code hooks, a CI workflow, reference code and a pre-ship checklist: [shiprules.gumroad.com](https://shiprules.gumroad.com).

## License

MIT (see [LICENSE](LICENSE)).

<sub>Keywords: cursor rules, .cursorrules, .mdc, cursor rules for nextjs, supabase rls, supabase using true, stripe webhook verification, stripe constructEvent raw body, CLAUDE.md template, AGENTS.md example, windsurf rules, codex agents.md, copilot instructions, unity 6 ai rules, godot 4 gdscript ai, godot 3 to 4, discord.js v14 slash commands, vibe coding security</sub>
