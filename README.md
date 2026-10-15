# ShipRules Free: AI coding rules for Cursor, Claude Code, Codex & Copilot

Free, tested **AI coding agent rules** that stop the most common mistakes AI makes in four stacks:

| Stack | What it stops | Files |
|---|---|---|
| **Next.js + Supabase + Stripe** | Supabase `service_role` key in client code, tables without **Row Level Security (RLS)**, secrets in `NEXT_PUBLIC_` | [`nextjs-supabase-stripe/`](nextjs-supabase-stripe) |
| **Unity 6** | Obsolete APIs (`FindObjectOfType`, `rb.velocity`), `?.` on Unity objects, unchecked `[SerializeField]` refs | [`unity6/`](unity6) |
| **Godot 4** | **Godot 3 code** in Godot 4 projects: `yield`, `export var`, `onready`, `setget`, `connect("sig", self, "m")` | [`godot4/`](godot4) |
| **discord.js v14** | "The application did not respond" (the 3-second interaction limit), hardcoded bot tokens, commands registered on startup | [`discordjs-v14/`](discordjs-v14) |

Each folder has the same rules in three formats:
- `.cursor/rules/*.mdc`: **Cursor rules** (current format with `description` / `globs` / `alwaysApply` frontmatter)
- `AGENTS.md`: **OpenAI Codex**, GitHub Copilot agent, Gemini CLI, Windsurf, Zed, Aider and other agents that read AGENTS.md
- `CLAUDE.md`: **Claude Code** (imports `AGENTS.md`)

## Install (30 seconds)
```bash
git clone https://github.com/otctrading101/shiprules-free
cp -r shiprules-free/godot4/. my-godot-game/   # or unity6/, nextjs-supabase-stripe/, discordjs-v14/
```
Already have an `AGENTS.md` or `CLAUDE.md`? Paste the rules into yours instead of overwriting it.

## Want the full packs?
The free set is 2 rules per stack. The paid **ShipRules** packs add the full rule set (6–7 rules), Copilot instructions, a **zero-dependency scanner** (leaked keys, missing RLS, Godot 3 syntax, obsolete Unity APIs, discord.js v13 code), Claude Code hooks, a CI workflow, reference code and a pre-ship checklist.

- [Ship-Safe SaaS Pack: Next.js + Supabase + Stripe ($15)](https://otctrader.gumroad.com/l/lztkjm)
- [Unity 6 Agent Pack ($12)](https://otctrader.gumroad.com/l/pegmfk)
- [Godot 4 Pack: stop AI writing Godot 3 code ($9)](https://otctrader.gumroad.com/l/tawprk)
- [Discord Bot Pack: discord.js v14 ($9)](https://otctrader.gumroad.com/l/qitubq)
- [**Bundle: all 4 ($29)**](https://otctrader.gumroad.com/l/qgwqqy)

## Sources
Rules were checked against the official docs: Cursor Rules, Claude Code memory, agents.md, the GitHub Copilot custom instructions, the Unity 6 Scripting API, Godot's "Upgrading from Godot 3 to Godot 4" guide and its `renames_map_3_to_4.cpp`, the discord.js v14 guide, and the Discord Gateway docs.

Rules guide your AI; they don't guarantee its output. Always review security-critical code.

## License
MIT (see [LICENSE](LICENSE)). Contributions welcome: open a PR with a rule plus a link to the official doc it's based on.

<sub>Keywords: cursor rules, .cursorrules, .mdc, cursor rules for nextjs, supabase rls, stripe webhook verification, CLAUDE.md template, AGENTS.md example, copilot instructions, unity 6 ai rules, godot 4 gdscript ai, godot 3 to 4, discord.js v14 slash commands, vibe coding security</sub>
