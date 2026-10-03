// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH (or RTK_BIN pointing at the binary).
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.
//
// Dual-shape plugin (zero dependencies, no @opencode/plugin import needed):
//   - OpenCode 2.x reads the plain-object default export's `id` + `setup()`
//     and registers `ctx.tool.hook("execute.before", ...)`.
//   - OpenCode 1.x (1.18.29+) calls `server()` and uses `tool.execute.before`.
// Works with the OpenCode CLI, Desktop/Electron, and Windows (node:child_process,
// PATHEXT-aware binary discovery) — no Bun/zx required.

import { execFile } from "node:child_process"
import { existsSync } from "node:fs"
import { homedir } from "node:os"
import { delimiter, join } from "node:path"

let cachedRtkPath: string | null = null

export function _resetCachedRtkPath(): void {
  cachedRtkPath = null
}

export function expandHome(filepath: string): string {
  return /^~[/\\]?/.test(filepath)
    ? join(homedir(), filepath.replace(/^~[/\\]?/, ""))
    : filepath
}

/**
 * Resolves the rtk binary from RTK_BIN, standard PATH, or common installation directories.
 */
export function resolveRtkPath(): string | null {
  if (cachedRtkPath && existsSync(cachedRtkPath)) return cachedRtkPath

  const envBin = process.env.RTK_BIN
  if (envBin) {
    const expanded = expandHome(envBin)
    if (existsSync(expanded)) return (cachedRtkPath = expanded)
  }

  const dirs = [
    ...(process.env.PATH ?? "").split(delimiter).filter(Boolean),
    join(homedir(), ".local", "bin"),
    join(homedir(), ".cargo", "bin"),
    "/opt/homebrew/bin",
    "/usr/local/bin",
  ]
  const exts =
    process.platform === "win32"
      ? (process.env.PATHEXT ?? ".EXE;.CMD;.BAT;.COM").split(";")
      : [""]

  for (const dir of dirs) {
    for (const ext of exts) {
      const fullPath = join(dir, `rtk${ext}`)
      if (existsSync(fullPath)) return (cachedRtkPath = fullPath)
    }
  }

  return (cachedRtkPath = null)
}

/**
 * Invokes `rtk rewrite <command>`.
 * Handles exit code 0 (Allow) and exit code 3 (Ask/Default) — `rtk rewrite`
 * exits non-zero (3) even on success. Discards partial stdout if the process
 * was terminated, killed by timeout, or exited with non-rewrite error codes
 * (Deny: 2, Defer: 1).
 */
export function runRtkRewrite(
  rtkBin: string,
  command: string,
  timeoutMs = 3000
): Promise<string | null> {
  return new Promise((resolve) => {
    execFile(
      rtkBin,
      ["rewrite", command],
      { encoding: "utf8", timeout: timeoutMs, windowsHide: true },
      (error, stdout) => {
        if (error) {
          if (error.killed || error.signal) return resolve(null)
          const exitCode = (error as unknown as { code?: number | string }).code
          if (exitCode !== 3) return resolve(null)
        }

        const output = String(stdout ?? "").trim()
        resolve(output && output !== command ? output : null)
      }
    )
  })
}

export async function tryRewriteCommand(
  toolName: unknown,
  command: unknown
): Promise<string | null> {
  const tool = String(toolName ?? "").toLowerCase()
  if ((tool !== "bash" && tool !== "shell") || typeof command !== "string" || !command.trim()) {
    return null
  }

  const rtkBin = resolveRtkPath()
  if (!rtkBin) return null

  try {
    return await runRtkRewrite(rtkBin, command)
  } catch {
    return null
  }
}

async function handleToolHook(tool: unknown, container: any, key: "command") {
  if (!container || typeof container !== "object") return
  const rewritten = await tryRewriteCommand(tool, container[key])
  if (rewritten) container[key] = rewritten
}

function warnMissingRtk(): boolean {
  const found = Boolean(resolveRtkPath())
  if (!found) console.warn("[rtk] rtk binary not found — plugin disabled")
  return found
}

/**
 * Universal OpenCode plugin for RTK.
 * Plain object with `id` and `setup(ctx)` matching OpenCode 2.x loader schema
 * validation, plus a `server()` method for OpenCode 1.x (1.18.29+) dual-shape
 * compatibility. V2 ignores `server()`; V1 ignores `setup()`.
 */
const RtkOpenCodePlugin = {
  id: "rtk",

  // OpenCode 2.x entrypoint
  async setup(ctx: any) {
    if (!warnMissingRtk()) return
    await ctx?.tool?.hook?.("execute.before", (e: any) =>
      handleToolHook(e?.tool, e?.input, "command")
    )
  },

  // OpenCode 1.x entrypoint (dual-shape support, 1.18.29+)
  async server() {
    if (!warnMissingRtk()) return {}
    return {
      "tool.execute.before": (input: any, output: any) =>
        handleToolHook(input?.tool, output?.args, "command"),
    }
  },
}

export default RtkOpenCodePlugin
export { RtkOpenCodePlugin }
