import { execFile } from "node:child_process"
import { promisify } from "node:util"

const run = promisify(execFile)

// Minimal structural typing for the plugin surface used here. OpenCode validates the
// default export as `{ id, setup | effect }`, so this standalone local plugin needs no
// `@opencode/plugin` package import (it is not resolvable in this runtime).
interface ToolBeforeEvent {
  tool?: string
  input?: unknown
}
interface PluginContext {
  tool: {
    hook(name: "execute.before", cb: (event: ToolBeforeEvent) => Promise<void> | void): Promise<unknown>
  }
}

// RTK OpenCode plugin (V2) — rewrites bash commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

export default {
  id: "rtk",
  async setup(ctx: PluginContext) {
    try {
      await run("rtk", ["--version"])
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", async (event) => {
      const tool = String(event.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return

      const input = event.input as { command?: unknown } | undefined
      if (!input || typeof input !== "object") return
      const command = input.command
      if (typeof command !== "string" || !command) return

      try {
        const { stdout } = await run("rtk", ["rewrite", command])
        const rewritten = String(stdout).trim()
        if (rewritten && rewritten !== command) {
          input.command = rewritten
        }
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    })
  },
}
