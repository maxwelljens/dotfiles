import { execFile } from "node:child_process"
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"
import { promisify } from "node:util"

const run = promisify(execFile)

// Minimal structural typing for the plugin surface used here. OpenCode validates the
// default export as `{ id, setup | effect }`, so this standalone local plugin needs no
// `@opencode/plugin` package import (it is not resolvable in this runtime).
interface SystemPart {
  type: string
  text?: string
}
interface ContextHookEvent {
  sessionID: string
  system: SystemPart[]
  messages: unknown[]
}
interface McpEditor {
  list(): Array<[string, { command?: string[] } | undefined]>
  set(name: string, config: unknown): void
}
interface SkillEditor {
  add(skill: Record<string, unknown>): void
  get(id: string): unknown
}
interface CommandInvocation {
  sessionID: string
  prompt?: { text?: string }
  delivery?: string
}
interface CommandEditor {
  add(def: { name: string; description: string; execute: (input: CommandInvocation) => Promise<void> }): void
}
interface PluginContext {
  location?: { project?: { directory?: string } }
  mcp: { transform(cb: (editor: McpEditor) => void): Promise<unknown> }
  skill: { transform(cb: (editor: SkillEditor) => void): Promise<unknown> }
  command: { transform(cb: (editor: CommandEditor) => void): Promise<unknown> }
  session: {
    hook(name: "context", cb: (event: ContextHookEvent) => Promise<void> | void): Promise<unknown>
    get(input: { sessionID: string }): Promise<{ directory?: string }>
    prompt(input: { sessionID: string; text: string; delivery?: string }): Promise<unknown>
    synthetic(input: { sessionID: string; text: string }): Promise<unknown>
  }
}

// codemap OpenCode plugin (V2) — structural ground truth for coding agents.
// Requires: codemap in PATH (https://github.com/JordanCoin/codemap).
//
// This is a thin delegating plugin: all analysis lives in the `codemap` CLI
// (`codemap context`, `codemap skill show`, `codemap blast-radius`, ...).
// To change what the answers contain, tune codemap itself — e.g. `.codemap/config.json`.
//
// What this plugin wires up:
//   1. MCP   — registers the `codemap mcp` stdio server unless one is already
//      configured (skips silently when `mcp_codemap` exists in opencode.jsonc).
//   2. Skills — mirrors codemap's skill library (hub-safety, refactor, ...) into
//      OpenCode skills so they auto-invoke by intent, including project-local
//      `.codemap/skills/` overrides that `codemap skill show` already resolves.
//   3. Commands — /codemap, /blast-radius, /codemap-handoff.
//   4. Session context — injects `codemap context --compact` into the system
//      prompt on a session's first model call (cached per project, 30 min TTL),
//      so the agent starts with structure, hubs, and working-set awareness.

const CONTEXT_TTL_MS = 30 * 60 * 1000
const CONTEXT_BYTES = 30_000
const SKILL_BYTES = 64 * 1024
const SKILLS_DIR = join(homedir(), ".local", "share", "opencode", "codemap-skills")

const contextCache = new Map<string, { at: number; text: string }>()

async function codemap(args: string[], cwd?: string, timeoutMs = 30_000): Promise<string> {
  const { stdout } = await run("codemap", args, {
    cwd,
    timeout: timeoutMs,
    maxBuffer: 16 * 1024 * 1024,
  })
  return String(stdout)
}

function clip(text: string, max: number): string {
  return text.length <= max ? text : `${text.slice(0, max)}\n…[truncated]`
}

// The session's working directory, so every codemap call runs against the
// project the session belongs to rather than the service process cwd.
async function sessionDir(ctx: PluginContext, sessionID: string): Promise<string | undefined> {
  try {
    const info = await ctx.session.get({ sessionID })
    if (info?.directory) return info.directory
  } catch {
    // fall through to the plugin location
  }
  return ctx.location?.project?.directory
}

async function contextFor(dir: string): Promise<string | undefined> {
  const hit = contextCache.get(dir)
  if (hit && Date.now() - hit.at < CONTEXT_TTL_MS) return hit.text
  try {
    const raw = await codemap(["context", "--compact"], dir, 15_000)
    const text =
      `codemap context for this project (structural ground truth):\n` +
      "```json\n" + clip(raw, CONTEXT_BYTES) + "\n```"
    contextCache.set(dir, { at: Date.now(), text })
    return text
  } catch {
    // A stale map beats no map; an empty scan must never break the model call.
    return hit?.text
  }
}

// `codemap skill list` prints one "  <name>  [source]  <description> (<keywords>)"
// line per skill; the name column is all we need from it.
function skillNamesFromList(out: string): string[] {
  const names: string[] = []
  for (const line of out.split("\n")) {
    const m = /^\s+(\S+)\s+\[\S+\]\s+/.exec(line)
    if (m) names.push(m[1])
  }
  return names
}

// `codemap skill show <name>` prints a small metadata block then the Markdown body.
function skillFromShow(name: string, out: string): Record<string, unknown> | undefined {
  const description = /^Description:\s*(.*)$/m.exec(out)?.[1]?.trim() ?? ""
  const keywords = (/^Keywords:\s*(.*)$/m.exec(out)?.[1] ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean)
  const metaEnd = /^Languages:.*$/m.exec(out) ?? /^Description:.*$/m.exec(out)
  const content = (metaEnd ? out.slice(metaEnd.index + metaEnd[0].length) : out).trim()
  if (!description && !content) return undefined

  // Builtins have no source file, so materialise one: real paths keep every
  // Skill.Info field honest and give users a browsable copy to edit.
  const location = join(SKILLS_DIR, `${name}.md`)
  try {
    mkdirSync(SKILLS_DIR, { recursive: true })
    const want = `# ${name}\n\n${content}\n`
    if (!existsSync(location) || readFileSync(location, "utf8") !== want) writeFileSync(location, want)
  } catch {
    // best effort — registration below still carries the content inline
  }
  return {
    id: `codemap-${name}`,
    name,
    description,
    keywords,
    location,
    content,
  }
}

export default {
  id: "codemap",
  async setup(ctx: PluginContext) {
    try {
      await run("codemap", ["--version"])
    } catch {
      console.warn("[codemap] codemap binary not found in PATH — plugin disabled")
      return
    }

    // 1. MCP — only register when nothing else already serves `codemap mcp`.
    try {
      await ctx.mcp.transform((editor) => {
        const served = editor.list().some(([, cfg]) => {
          const cmd = Array.isArray(cfg?.command) ? cfg.command.map(String) : []
          return cmd.some((part) => part.endsWith("codemap")) && cmd.includes("mcp")
        })
        if (!served) editor.set("mcp_codemap", { type: "local", command: ["codemap", "mcp"], enabled: true })
      })
    } catch (err) {
      console.warn("[codemap] mcp registration skipped:", err)
    }

    // 2. Skills — load codemap's library first (transforms are synchronous).
    try {
      const list = await codemap(["skill", "list"])
      const skills: Array<Record<string, unknown>> = []
      for (const name of skillNamesFromList(list)) {
        try {
          const skill = skillFromShow(name, await codemap(["skill", "show", name]))
          if (skill) skills.push(skill)
        } catch {
          // one unreadable skill must not cost the others
        }
      }
      await ctx.skill.transform((editor) => {
        for (const skill of skills) {
          try {
            const id = String(skill.id)
            if (!editor.get(id)) editor.add(skill)
          } catch (err) {
            console.warn(`[codemap] skill ${skill.id} skipped:`, err)
          }
        }
      })
    } catch (err) {
      console.warn("[codemap] skill registration skipped:", err)
    }

    // 3. Commands.
    try {
      await ctx.command.transform((editor) => {
        editor.add({
          name: "codemap",
          description: "codemap context: project structure, hubs, and working set (args = optional focus)",
          execute: async ({ sessionID, prompt, delivery }) => {
            try {
              const focus = String(prompt?.text ?? "").trim()
              const dir = await sessionDir(ctx, sessionID)
              const raw = await codemap(focus ? ["context", "--for", focus] : ["context", "--compact"], dir, 15_000)
              const ask = focus
                ? `Summarize the structure, dependencies, and risks relevant to: ${focus}`
                : "Give me a brief orientation: what this project is, where the hubs are, and anything risky to touch."
              await ctx.session.prompt({
                sessionID,
                delivery,
                text: `codemap context:\n\`\`\`json\n${clip(raw, CONTEXT_BYTES)}\n\`\`\`\n\n${ask}`,
              })
            } catch (err) {
              await ctx.session.synthetic({ sessionID, text: `[codemap] context failed: ${String(err)}` })
            }
          },
        })
        editor.add({
          name: "blast-radius",
          description: "codemap blast-radius: what breaks if the current changes land (args = ref, default main)",
          execute: async ({ sessionID, prompt, delivery }) => {
            try {
              const ref = String(prompt?.text ?? "").trim() || "main"
              const dir = await sessionDir(ctx, sessionID)
              const raw = await codemap(["blast-radius", "--text", "--ref", ref, "."], dir, 60_000)
              await ctx.session.prompt({
                sessionID,
                delivery,
                text:
                  `codemap blast-radius vs ${ref}:\n\`\`\`text\n${clip(raw, CONTEXT_BYTES)}\n\`\`\`\n\n` +
                  "Summarize the blast radius and what needs testing.",
              })
            } catch (err) {
              await ctx.session.synthetic({ sessionID, text: `[codemap] blast-radius failed: ${String(err)}` })
            }
          },
        })
        editor.add({
          name: "codemap-handoff",
          description: "Save a codemap handoff so another agent can continue with full context",
          execute: async ({ sessionID }) => {
            try {
              const dir = await sessionDir(ctx, sessionID)
              const raw = await codemap(["handoff", "."], dir, 30_000)
              await ctx.session.synthetic({
                sessionID,
                text: `[codemap] handoff saved.\n${clip(raw, 4_000)}`,
              })
            } catch (err) {
              await ctx.session.synthetic({ sessionID, text: `[codemap] handoff failed: ${String(err)}` })
            }
          },
        })
      })
    } catch (err) {
      console.warn("[codemap] command registration skipped:", err)
    }

    // 4. Session context — first model call of a session only; the hook itself
    // never throws, so a codemap failure can never block a model call.
    try {
      await ctx.session.hook("context", async (event) => {
        try {
          if (event.messages.length > 1) return
          const dir = await sessionDir(ctx, event.sessionID)
          if (!dir) return
          const text = await contextFor(dir)
          if (text) event.system.push({ type: "text", text })
        } catch {
          // never break the model call
        }
      })
    } catch (err) {
      console.warn("[codemap] context hook skipped:", err)
    }

    console.log("[codemap] plugin ready (mcp, skills, commands, session context)")
  },
}
