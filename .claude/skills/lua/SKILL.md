---
name: lua
description: Lua development guidelines for World of Warcraft addons — the restricted addon sandbox, WoW API idioms, and this project's conventions.
---

# WoW Addon Lua Development

You are an expert in Lua as used inside the World of Warcraft addon sandbox — not general-purpose Lua, and not another embedding like Love2D or Corona.

## The Sandbox

- No `require()`, no `os`/`io` libraries, no filesystem access. Dependencies are wired via `.toc` load order — every file listed loads into the same environment sequentially.
- Each file receives `addonName, addonTable = ...` as its two vararg values. Use the shared `addonTable` (commonly `addon`) to pass state and functions between files instead of globals.
- Never declare top-level globals for internal state. Locals plus the shared addon table are the only communication channel between files — a `local function foo()` in one file is invisible to another.
- Persistence is via `SavedVariables` / `SavedVariablesPerCharacter` declared in the `.toc`. These are plain global tables (e.g. `CharacterSpec`) that WoW populates on `ADDON_LOADED` and flushes to disk on logout/reload — there is no other way to write to disk from an addon.
- Everything else in the sandbox — `pcall`, `string`, `table`, `math`, standard control flow — behaves like normal Lua 5.1.

## Structure and Naming

- One file per logical unit (per data domain, per feature); wire load order explicitly in the `.toc`.
- `camelCase` for locals/functions, `UPPERCASE` for constant-like data keys (e.g. class/spec names), matching this codebase's existing style.
- Prefer `addon:MethodName()` (colon-call, self-passing) for anything that reads as a public API on the addon table; plain `local function` for file-private helpers.
- Never shadow an outer local with a parameter or loop variable of the same name. There's no linter running against this sandbox, so a shadowing bug silently breaks a feature until someone traces it out by hand — assign shadowed values to a differently-named parameter instead.
- Keep tables of static data (talent lists, etc.) as plain nested tables, not metatable-driven objects — this project has no OOP layer, and introducing one for data-only files adds indirection without benefit.

## Events and Frames

- Model behavior as event-driven, not polling. Use `CreateFrame`, `RegisterEvent`, and a single `OnEvent` dispatcher rather than `OnUpdate` unless something genuinely needs per-frame ticking.
- Guard `ADDON_LOADED` handlers with an addon-name check (`arg1 == "NextTalent"`) since the event fires once per addon that loads, not just yours.
- Cache values an event fires on every incidental change (e.g. unspent talent points) and diff against the previous value if you only want to react to actual changes, not event noise.

## Error Handling

- Use `pcall`/`xpcall` around anything calling into user-supplied or optional data.
- Prefer `if x == nil then return end` guard clauses over deep nesting — WoW API functions return `nil` liberally (missing unit, addon not loaded yet, no spec selected), and every one of those needs an explicit check.
- `assert()` is for programmer-error invariants (a data table you control should never be malformed); don't use it for expected runtime conditions like "player hasn't selected a spec yet" — that's a normal state, handled with a message, not an error.

## Slash Commands and Output

- Register via `SLASH_MYADDON1`/`SLASH_MYADDON2`, etc. and a single `SlashCmdList["MYADDON"]` dispatcher; parse the command word out of the raw message string yourself.
- Use color escape codes (`|cffRRGGBBtext|r`) for chat output, not raw `print()` for anything user-facing — route it through a shared helper (`PrintMessage`/`PrintError`) so formatting stays consistent across the addon.

## Performance

- Addons run inside the client's frame loop, so anything hooked to a frequent event (`OnUpdate`, `COMBAT_LOG_EVENT_UNFILTERED`) must be cheap — throttle or early-return aggressively.
- Avoid creating tables inside handlers for frequent events; hoist reusable tables to module scope.
- Don't chase general Lua micro-optimizations (local-caching globals, avoiding table churn) in handlers that only run a handful of times per session, like slash commands or level-up events — it's not worth the readability cost here.

## Testing

- The WoW client isn't available outside the game, so tests run under plain desktop Lua: `loadfile()` the addon files against a stubbed `addon` table (see `specs.test.lua`, `utils.test.lua`) instead of real WoW globals.
- Any test path that needs a real WoW API function (`GetTalentInfo`, `UnitLevel`, `GetUnspentTalentPoints`, etc.) has to stub it — there is no headless WoW client to invoke in CI.
