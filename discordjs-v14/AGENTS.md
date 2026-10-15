# Project instructions: discord.js v14 (ShipRules free starter)

## Slash commands & interactions
- Define with `SlashCommandBuilder`; names lowercase, 1-32 chars; descriptions required.
- Register in `deploy-commands.js` via `REST` + `Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID)` while developing, and `Routes.applicationCommands(CLIENT_ID)` for production. NEVER call `rest.put` inside `ClientReady`/startup: it burns rate limits on every restart.
- **3-second rule:** Discord must get an initial response within 3 seconds or the interaction fails. If the handler awaits ANYTHING slow (DB, HTTP, AI, file I/O), call `await interaction.deferReply()` FIRST, then `editReply()`. The token is then valid for 15 minutes.
- Respond exactly once initially (`reply` OR `deferReply` OR `deferUpdate`/`update` for components); use `followUp()`/`editReply()` after. Check `interaction.deferred || interaction.replied` in error handlers.
- Wrap every `execute` in try/catch; on error reply/followUp with an ephemeral message (`flags: MessageFlags.Ephemeral`).
- Check permissions server-side (`interaction.memberPermissions.has(...)`), and set `setDefaultMemberPermissions` for admin commands. Use `setDMPermission`/contexts as appropriate.
- Validate user-supplied options (length, URLs, mentions). Use `allowedMentions: { parse: [] }` when echoing user text so the bot can't be used to ping @everyone.
- Component collectors: always set `time` and a `filter` on the invoking user's id.

## Token & secret safety
- The bot token is read ONLY from `process.env.DISCORD_TOKEN` (`os.environ` in Python). Never hardcode it, put it in `config.json`, log it, or send it in a message.
- `.env` and any `config.json` with secrets are gitignored; commit `.env.example`.
- If a token was ever committed or pasted publicly, tell the user to reset it in the Developer Portal immediately (Discord also auto-invalidates tokens found in public GitHub repos).
- Never `eval` user input. No "eval" or "exec" owner commands unless the user explicitly asks, and then locked to the owner's user id.
- Don't log full interaction payloads (they contain tokens); log ids only.

---
Free ShipRules starter rules (MIT). Full pack with more rules, a scanner, hooks and a checklist: https://otctrader.gumroad.com/l/qitubq
