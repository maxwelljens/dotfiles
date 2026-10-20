// s1router — System-One model routing for OpenCode.
// GENERATED FILE: bundled from /media/Development/kevfefe/opencode-plugin-s1router
// (deno bundle src/index.ts). Edit the source, then re-run:
//   deno task install-global
// Config: ~/.config/opencode/s1router.jsonc
// src/config.ts
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import process from "node:process";
var FILE_NAMES = [
  "s1router.jsonc",
  "s1router.json"
];
function configDir(env = process.env) {
  const xdg = env["XDG_CONFIG_HOME"];
  const base = xdg && xdg.length > 0 ? xdg : join(homedir(), ".config");
  return join(base, "opencode");
}
function stripJsonc(text) {
  let out = "";
  let i = 0;
  let inString = false;
  let escape = false;
  while (i < text.length) {
    const c = text[i];
    if (inString) {
      out += c;
      if (escape) escape = false;
      else if (c === "\\") escape = true;
      else if (c === '"') inString = false;
      i++;
      continue;
    }
    if (c === '"') {
      inString = true;
      out += c;
      i++;
      continue;
    }
    if (c === "/" && text[i + 1] === "/") {
      while (i < text.length && text[i] !== "\n") i++;
      continue;
    }
    if (c === "/" && text[i + 1] === "*") {
      i += 2;
      while (i < text.length && !(text[i] === "*" && text[i + 1] === "/")) i++;
      i += 2;
      continue;
    }
    if (c === "}" || c === "]") {
      for (; ; ) {
        const m = /,\s*$/.exec(out);
        if (!m) break;
        out = out.slice(0, out.length - m[0].length);
      }
    }
    out += c;
    i++;
  }
  return out;
}
function mergeOptions(base, over) {
  const DEEP = /* @__PURE__ */ new Set([
    "decision",
    "ladder",
    "hysteresis",
    "rater"
  ]);
  const out = {
    ...base
  };
  for (const [k, v] of Object.entries(over)) {
    if (v === void 0) continue;
    const prev = out[k];
    if (DEEP.has(k) && typeof v === "object" && v !== null && !Array.isArray(v) && typeof prev === "object" && prev !== null && !Array.isArray(prev)) {
      out[k] = {
        ...prev,
        ...v
      };
    } else {
      out[k] = v;
    }
  }
  return out;
}
async function loadConfig(dir = configDir()) {
  for (const name of FILE_NAMES) {
    const path = join(dir, name);
    let text;
    try {
      text = await readFile(path, "utf8");
    } catch (err) {
      if (err.code === "ENOENT") continue;
      return {
        options: {},
        source: path,
        error: String(err)
      };
    }
    try {
      const options = JSON.parse(stripJsonc(text));
      return {
        options,
        source: path
      };
    } catch (err) {
      return {
        options: {},
        source: path,
        error: `parse error: ${String(err)}`
      };
    }
  }
  return {
    options: {},
    source: null
  };
}

// src/client.ts
var emptyStats = () => ({
  calls: 0,
  failures: 0,
  inputTokens: 0,
  outputTokens: 0,
  totalMs: 0,
  cacheHits: 0
});
var ScoreClient = class {
  opts;
  stats;
  cache;
  cacheLimit;
  constructor(opts = {}) {
    this.opts = opts;
    this.stats = emptyStats();
    this.cache = /* @__PURE__ */ new Map();
    this.cacheLimit = 2e3;
  }
  get baseUrl() {
    return (this.opts.baseUrl ?? "http://localhost:11434").replace(/\/$/, "");
  }
  get model() {
    return this.opts.model ?? "tev1:4b";
  }
  snapshot() {
    return {
      ...this.stats
    };
  }
  async score(state, question) {
    const key = `${state} ${JSON.stringify(question)}`;
    const hit = this.cache.get(key);
    if (hit) {
      this.stats.cacheHits++;
      return {
        answer: hit,
        ms: 0,
        inputTokens: 0,
        outputTokens: 0
      };
    }
    const started = performance.now();
    try {
      const res = await fetch(`${this.baseUrl}/v1/systemone`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          model: this.model,
          state,
          questions: {
            q: question
          }
        }),
        signal: AbortSignal.timeout(this.opts.timeoutMs ?? 6e3)
      });
      if (!res.ok) throw new Error(`systemone ${res.status}: ${await res.text()}`);
      const data = await res.json();
      const ms = performance.now() - started;
      this.stats.calls++;
      this.stats.inputTokens += data.usage?.input_tokens ?? 0;
      this.stats.outputTokens += data.usage?.output_tokens ?? 0;
      this.stats.totalMs += ms;
      const answer = data.answers?.q ?? null;
      if (answer) {
        if (this.cache.size >= this.cacheLimit) {
          const first = this.cache.keys().next();
          if (!first.done) this.cache.delete(first.value);
        }
        this.cache.set(key, answer);
      }
      return {
        answer,
        ms,
        inputTokens: data.usage?.input_tokens ?? 0,
        outputTokens: data.usage?.output_tokens ?? 0
      };
    } catch (err) {
      this.stats.failures++;
      throw err;
    }
  }
};

// src/rater.ts
var DEFAULT_RATER_OPTIONS = {
  maxEvents: 12,
  detailChars: 200,
  maxChars: 8e3
};
var COMPLEXITY_LEVELS = [
  "trivial: a single known fact, a one-line edit, or a lookup with no uncertainty",
  "simple: one file, one clear procedure, no unknowns",
  "moderate: a small change spanning a couple of files or needing one inference",
  "complex: cross-file reasoning, an unfamiliar subsystem, or a diagnosis with multiple candidates",
  "hard: an open-ended design or debugging problem with no obvious solution path"
];
var COMPLEXITY_QUESTION = {
  type: "score",
  instructions: "Rate how hard this request is for a coding agent right now, given the recent activity. Judge the work needed to complete it correctly, not the length of the request text.",
  criteria: COMPLEXITY_LEVELS
};
var clip = (s, n) => s.length <= n ? s : s.slice(0, n - 1) + "\u2026";
function buildRaterState(ask, events, opts) {
  const digest = events.slice(-opts.maxEvents).map((e) => {
    const mark = e.kind === "error" ? "\u2717" : e.kind === "tool" ? e.ok === false ? "\u2717" : "\u2713" : "\u2022";
    return `${mark} ${e.label}: ${clip(e.detail, opts.detailChars)}`;
  }).join("\n");
  const header = `request: ${clip(ask, 600)}`;
  const full = `${header}
recent activity:
${digest}`;
  if (full.length <= opts.maxChars) return full;
  return `${header}
recent activity:
\u2026
${full.slice(-opts.maxChars + header.length - 20)}`;
}
function levelLabel(score) {
  const names = [
    "trivial",
    "simple",
    "moderate",
    "complex",
    "hard"
  ];
  return names[Math.max(0, Math.min(4, Math.round(score)))];
}

// src/policy.ts
var DEFAULT_HYSTERESIS = {
  upThreshold: 2,
  downThreshold: 1,
  downStreak: 2,
  bootstrapRatings: 2
};
var initialState = () => ({
  tier: "cheap",
  upStreak: 0,
  downStreak: 0,
  ratings: 0,
  lastScore: null
});
function route(state, score, currentTier, cfg = DEFAULT_HYSTERESIS) {
  const next = {
    ...state,
    ratings: state.ratings + 1,
    lastScore: score,
    upStreak: score >= cfg.upThreshold ? state.upStreak + 1 : 0,
    downStreak: score <= cfg.downThreshold ? state.downStreak + 1 : 0
  };
  if (score >= cfg.upThreshold && currentTier === "cheap") {
    next.tier = "strong";
    return {
      decision: {
        action: "switch",
        tier: "strong",
        reason: `score ${score.toFixed(2)} >= ${cfg.upThreshold} \u2192 escalate`
      },
      state: next
    };
  }
  if (currentTier === "strong" && next.downStreak >= cfg.downStreak && next.ratings > cfg.bootstrapRatings) {
    next.tier = "cheap";
    return {
      decision: {
        action: "switch",
        tier: "cheap",
        reason: `${next.downStreak} consecutive scores <= ${cfg.downThreshold} \u2192 de-escalate`
      },
      state: next
    };
  }
  next.tier = currentTier;
  return {
    decision: {
      action: "keep",
      tier: currentTier,
      reason: score >= cfg.upThreshold ? `score ${score.toFixed(2)} already on strong` : next.downStreak > 0 ? `simple vote ${next.downStreak}/${cfg.downStreak}` : `score ${score.toFixed(2)} within band`
    },
    state: next
  };
}

// src/router.ts
var S1Router = class {
  opts;
  client;
  ladder;
  hysteresis;
  raterOpts;
  state;
  steps;
  switches;
  skips;
  constructor(opts = {}, deps) {
    this.opts = opts;
    this.state = initialState();
    this.steps = 0;
    this.switches = 0;
    this.skips = 0;
    this.client = deps?.client ?? new ScoreClient(opts.decision);
    this.ladder = {
      cheap: opts.ladder?.cheap,
      strong: opts.ladder?.strong ?? {
        providerID: "opencode-go",
        id: "deepseek-v4-pro"
      }
    };
    this.hysteresis = {
      ...DEFAULT_HYSTERESIS,
      ...opts.hysteresis
    };
    this.raterOpts = {
      ...DEFAULT_RATER_OPTIONS,
      ...opts.rater
    };
  }
  /** Restore a persisted state (adapter reloads this from storage). */
  restore(state) {
    this.state = state;
  }
  snapshotState() {
    return {
      ...this.state
    };
  }
  stats() {
    return {
      ...this.client.snapshot(),
      steps: this.steps,
      switches: this.switches,
      skips: this.skips
    };
  }
  /** Which tier the ladder maps to; null when the ladder cannot express it
   * (cheap unset AND running on the strong model with nothing to go to). */
  targetFor(tier, current) {
    if (tier === "strong") return this.ladder.strong;
    return this.ladder.cheap ?? null;
  }
  /** One agent-loop step. Never throws: every failure degrades to "leave
   * the session alone". */
  async step(input) {
    const started = performance.now();
    this.steps++;
    const now = () => performance.now() - started;
    if (!this.ladder.strong) {
      this.skips++;
      return {
        rated: false,
        score: null,
        label: null,
        action: "skip",
        tier: null,
        target: null,
        reason: "no strong tier configured",
        ms: now()
      };
    }
    const state = buildRaterState(input.ask, input.events, this.raterOpts);
    let score;
    try {
      const res = await this.client.score(state, COMPLEXITY_QUESTION);
      if (res.answer === null) throw new Error("no answer");
      score = res.answer.score;
    } catch {
      this.skips++;
      return {
        rated: false,
        score: null,
        label: null,
        action: "skip",
        tier: null,
        target: null,
        reason: `rater unavailable (${this.opts.onRaterFailure ?? "default"} policy)`,
        ms: now()
      };
    }
    const currentTier = this.same(input.currentModel, this.ladder.strong) ? "strong" : "cheap";
    const { decision, state: next } = route(this.state, score, currentTier, this.hysteresis);
    this.state = next;
    if (decision.action === "keep") {
      return {
        rated: true,
        score,
        label: levelLabel(score),
        action: "keep",
        tier: decision.tier,
        target: null,
        reason: decision.reason,
        ms: now()
      };
    }
    const target = this.targetFor(decision.tier, input.currentModel);
    if (!target || this.same(target, input.currentModel)) {
      return {
        rated: true,
        score,
        label: levelLabel(score),
        action: "keep",
        tier: decision.tier,
        target: null,
        reason: "cheap tier is the session default \u2014 no switch needed",
        ms: now()
      };
    }
    this.switches++;
    return {
      rated: true,
      score,
      label: levelLabel(score),
      action: "switch",
      tier: decision.tier,
      target,
      reason: decision.reason,
      ms: now()
    };
  }
  same(a, b) {
    return a.providerID === b.providerID && a.id === b.id;
  }
};

// src/index.ts
var DEFAULT_AGENTS = [
  "build",
  "plan"
];
var STATE_PREFIX = "s1router/session/";
var plugin = {
  id: "s1router",
  async setup(ctx) {
    const fileCfg = await loadConfig();
    const options = mergeOptions(ctx.options ?? {}, fileCfg.options);
    if (fileCfg.error) {
      console.error(`[s1router] config ${fileCfg.source} unreadable (${fileCfg.error}); using defaults`);
    }
    if (options.disabled) return;
    const agents = new Set(options.agents ?? DEFAULT_AGENTS);
    const cadence = options.cadence ?? "every-step";
    const routers = /* @__PURE__ */ new Map();
    const routerFor = (sessionID) => {
      let r = routers.get(sessionID);
      if (!r) {
        r = new S1Router(options);
        routers.set(sessionID, r);
        void ctx.storage.get(STATE_PREFIX + sessionID).then((saved) => {
          if (saved) r.restore(saved);
        }).catch(() => {
        });
      }
      return r;
    };
    const persist = (sessionID, r) => {
      const payload = JSON.parse(JSON.stringify(r.snapshotState()));
      void ctx.storage.set(STATE_PREFIX + sessionID, payload).catch(() => {
      });
    };
    const announce = (sessionID, text) => {
      void ctx.session.synthetic({
        sessionID,
        text
      }).catch(() => {
      });
    };
    await ctx.session.hook("context", async (event) => {
      if (!agents.has(event.agent)) return;
      const router = routerFor(event.sessionID);
      const ask = latestUserText(event.messages);
      if (!ask) return;
      if (cadence === "per-turn" && lastToolPart(event.messages)) return;
      const events = digestEvents(event.messages);
      const currentModel = {
        providerID: event.model.providerID,
        id: event.model.id
      };
      let result;
      try {
        result = await router.step({
          ask,
          events,
          currentModel
        });
      } catch {
        return;
      }
      if (result.action === "switch" && result.target) {
        try {
          await ctx.session.switchModel({
            sessionID: event.sessionID,
            model: result.target
          });
          announce(event.sessionID, `\u2194 model switch: ${result.label} (${result.score?.toFixed(1)}) \u2192 ${result.target.id} \u2014 ${result.reason}`);
        } catch (err) {
          announce(event.sessionID, `\u2194 switch to ${result.target.id} failed (${err.message}); staying on ${currentModel.id}`);
        }
      } else if (result.action === "skip" && result.reason.startsWith("rater")) {
        console.error(`[s1router] ${result.reason}`);
      }
      persist(event.sessionID, router);
    });
    const strong = options.ladder?.strong;
    if (strong) {
      await ctx.session.hook("compaction", async (event) => {
        if (!agents.has(event.agent)) return;
        if (event.model.providerID === strong.providerID && event.model.id === strong.id) return;
        try {
          await ctx.session.switchModel({
            sessionID: event.sessionID,
            model: strong
          });
          announce(event.sessionID, `\u2194 compaction pinned to ${strong.id}`);
        } catch {
        }
      });
    }
    await ctx.command.transform((editor) => {
      editor.add({
        name: "routing-stats",
        description: "Show System-One router statistics for this session",
        execute: async ({ sessionID }) => {
          const r = routers.get(sessionID);
          if (!r) {
            await ctx.session.synthetic({
              sessionID,
              text: "s1router: no ratings recorded yet for this session."
            });
            return;
          }
          const s = r.stats();
          const st = r.snapshotState();
          await ctx.session.synthetic({
            sessionID,
            text: [
              `s1router: ${s.steps} steps rated, ${s.switches} switches, ${s.skips} skips.`,
              `State: tier=${st.tier}, last score=${st.lastScore?.toFixed(2) ?? "n/a"}, up-streak=${st.upStreak}, down-streak=${st.downStreak}/${r.stats().steps > 0 ? "2" : "2"}.`,
              `Rater: ${s.calls} calls, ${s.inputTokens} in / ${s.outputTokens} out tokens, ${Math.round(s.totalMs)}ms, ${s.cacheHits} cache hits, ${s.failures} failures.`
            ].join("\n")
          });
        }
      });
    });
  }
};
var src_default = plugin;
function latestUserText(messages) {
  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i];
    if (msg?.role !== "user") continue;
    const texts = [];
    for (const part of msg.parts ?? []) {
      const p = part;
      if (p.type === "text" && typeof p.text === "string") texts.push(p.text);
    }
    const text = texts.join("\n").trim();
    if (text) return text;
  }
  return null;
}
function lastToolPart(messages) {
  const last = messages[messages.length - 1];
  if (!last?.parts) return false;
  return last.parts.some((p) => p.type === "tool");
}
function digestEvents(messages) {
  const events = [];
  for (const raw of messages) {
    const msg = raw;
    if (!msg) continue;
    if (msg.role === "user") {
      for (const part of msg.parts ?? []) {
        const p = part;
        if (p.type === "text" && p.text) {
          events.push({
            kind: "ask",
            label: "user",
            detail: p.text
          });
        }
      }
    }
    for (const part of msg.parts ?? []) {
      const p = part;
      if (p.type !== "tool" || !p.tool) continue;
      const status = p.state?.status;
      const output = typeof p.state?.output === "string" ? p.state.output : typeof p.state?.title === "string" ? p.state.title : "";
      if (status === "error") {
        events.push({
          kind: "error",
          label: p.tool,
          detail: output || "failed",
          ok: false
        });
      } else {
        events.push({
          kind: "tool",
          label: p.tool,
          detail: output || "(no output)",
          ok: true
        });
      }
    }
  }
  return events;
}
export {
  src_default as default
};
