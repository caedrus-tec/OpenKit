# AGENTS.md

## Purpose
OpenKit provides a macOS installer and launcher for OpenCode CLI.
Use this file as the operating manual for agentic work in this repo.

## Repo layout
- `openkit_installer/` holds the user-facing macOS scripts.
- `openkit_installer/OpenCode Installer.command` installs OpenCode and guides setup.
- `openkit_installer/OpenCode Launcher.command` opens a folder and runs OpenCode in it.
- `openkit_installer/README.md` documents UX and behavior.
- `memsys3/` is the memory system for agent context.
- `README.md` is the project overview for humans and agents.

## Build / lint / test commands
There is no formal build system, linter, or test runner configured.

Syntax checks (closest to lint):
- `bash -n "openkit_installer/OpenCode Installer.command"`
- `bash -n "openkit_installer/OpenCode Launcher.command"`

Single-test command:
- Not applicable (no test framework configured).

Manual smoke checks (macOS):
- Double-click installer; verify Homebrew + OpenCode flow.
- Choose local mode; verify Ollama model pull completes.
- Double-click launcher; verify Finder opens and OpenCode runs in chosen folder.
- Optional: verify remote auth flow opens provider pages and `opencode auth login` works.

## Runtime entry points
- Installer: `openkit_installer/OpenCode Installer.command`
- Launcher: `openkit_installer/OpenCode Launcher.command`

## UX goals (non-negotiable)
- Terminal visible at all times.
- Friendly, step-by-step prompts.
- Safe defaults; no silent destructive behavior.
- Spanish user-facing messages (ASCII only, no accents).
- Minimize friction for non-technical users.

## Script structure (preferred flow)
- Define constants and paths at the top.
- Export PATH with Homebrew locations early.
- Detect required tools (brew, opencode, ollama).
- Prompt for language and auth flow with safe defaults.
- Apply config writes only after explicit confirmation.
- Verify install and surface quick status.
- End with a clear next step and pause to close.

## Code style guidelines (Bash)
- Shebang: keep `#!/bin/bash`.
- Indentation: 2 spaces, no tabs.
- Line length: keep prompts/logs short and readable.
- Encoding: ASCII only in user-facing text and scripts.
- Variables: uppercase constants (`OLLAMA_MODEL`), descriptive names for paths (`LANG_CONFIG_FILE`).
- Booleans: use string `true`/`false`; compare explicitly.
- Quoting: always quote paths and variables (`"$VAR"`).
- Imports: avoid `source`; if needed, use `SCRIPT_DIR` + absolute paths.
- Command discovery: prefer `command -v`; fall back to `/opt/homebrew/bin` and `/usr/local/bin`.
- PATH: `export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"` near the top.
- Prompts: use `read -r -p`; set defaults with `${VAR:-default}`.
- Menus: use `case` statements; include a safe default branch.
- Tests: keep to `[`/`]` for simple checks; avoid complex Bashisms.
- Arithmetic: use `$(( ... ))` for integer math.
- Here-docs: use `cat << 'EOF'` for literal JSON; unquoted `EOF` only when interpolation is needed.
- Optional commands: guard with `|| true` when failure is non-fatal (e.g., `open -a Ollama`).
- Functions: avoid unless needed; keep them short and linear.
- External deps: do not add Python/Node or new system deps without a strong reason.

## Error handling expectations
- On failure, print a clear `ERROR: ...` message.
- Pause before exit: `read -r -p "Pulsa Enter para cerrar... " _`.
- Exit non-zero on hard failures; exit 0 for user-cancel paths.
- Do not overwrite existing user configs without explicit confirmation.
- Create timestamped backups when overwriting config files.
- Validate required tools exist before use.
- For disk space checks, warn and allow cancel.

## JSON/config formatting
- Keep JSON pretty-printed with 2-space indents.
- Preserve `$schema` and key order where practical.
- Keep model names consistent (`qwen2.5-coder:14b`).
- Write configs only into documented paths.

## Config and data locations
- Auth credentials: `~/.local/share/opencode/auth.json`
- Main config: `~/.config/opencode/opencode.json`
- Local-mode config: `~/.config/opencode/opencode.ollama.json`
- Language config: `~/.config/opencode/opencode.lang.json`
- Language instructions: `~/.config/opencode/instructions-language.md`
- Installer no-pause flag: `~/.config/opencode/installer-no-pause`
- Desktop launcher target: `~/Desktop/OpenCode Launcher.command`

## OpenCode configuration rules
- If `opencode.json` exists, do not overwrite it.
- Write local-mode config to `opencode.ollama.json` instead.
- If no main config exists, write local-mode config to `opencode.json`.
- Language instructions always go to `instructions-language.md`.
- Launcher selects `OPENCODE_CONFIG` based on local or language config.

## Local model defaults
- Default model: `qwen2.5-coder:14b`
- Approx model size: 8-9 GB
- Approx total install size: 9-11 GB

## Homebrew and Ollama behavior
- Install Homebrew only if missing.
- After install, run `brew shellenv` for current session.
- Use OpenCode tap: `brew install anomalyco/tap/opencode`.
- Start Ollama with `open -a Ollama` before pulling models.
- Use `ollama pull` to fetch the model.
- If Ollama install fails, exit with an error prompt.

## Finder / Terminal behavior
- Use `open "$FOLDER_PATH"` to show the folder.
- Run OpenCode from the selected folder (`cd` then `opencode`).

## Adding new scripts
- Use the `.command` extension for Finder double-click support.
- Keep names prefixed with `OpenCode` and human-readable.
- Ensure executable bit is set (`chmod +x`).
- Keep Terminal visible; do not run silently in background.
- Use `osascript` for folder selection prompts when needed.
- Avoid adding new GUI dependencies unless required.
- Keep prompts short and default to the safest option.

## Documentation updates
- Keep `openkit_installer/README.md` aligned with script behavior.
- If prompts or config paths change, update README in the same change.
- Note UX changes in memsys3 if they impact workflows.

## memsys3 usage (context only)
- memsys3 is for persistent context; OpenKit is the product.
- Start sessions with `@memsys3/prompts/newSession.md`.
- Record changes in `memsys3/memory/full/sessions.yaml`.
- Keep `memsys3/memory/project-status.yaml` current.
- Add ADRs to `memsys3/memory/full/adr.yaml` for major decisions.
- Compile context with `@memsys3/prompts/compile-context.md` when needed.

## Security and privacy
- Do not log or store API keys in repo files.
- Avoid printing secrets to Terminal output.
- Do not modify user files outside documented paths.
- Do not add telemetry or network calls without explicit requirement.

## Cursor / Copilot rules
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` found.
- If added later, summarize them here and follow them.
