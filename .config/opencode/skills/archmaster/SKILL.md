---
name: archmaster
description: Create polished, validated architecture, workflow, sequence, data-flow, and lifecycle/state diagrams as explorable standalone HTML with inline SVG, dark/light themes, optional trace motion, and PNG/SVG export from the viewer. Accept plain-language requirements or pasted Mermaid flowchart, sequenceDiagram, and stateDiagram input; inspect repository evidence when the diagram must reflect real code. Use when the user asks to visualize system architecture, infrastructure, cloud/security/network topology, technical workflows, API call sequences, request lifecycles, data pipelines, ETL/ELT, data lineage, state machines, or to convert/beautify Mermaid.
license: EUPL-1.2
metadata:
  version: "0.1"
  author: mjensen
  based_on: tt-a1i/archify (MIT, v2.16)
---

# Archmaster

Create a self-contained, interactive HTML diagram from a small typed JSON specification. Static output is the default; enable motion only when the user asks for a demo or presentation.

Archmaster is a Deno fork of Archify. The `archmaster` binary is self-contained: no Node, no network access, no update checks.

## Fast authoring path

Use this bounded path for ordinary generation.

1. Choose `architecture`, `workflow`, `sequence`, `dataflow`, or `lifecycle` from the question.
2. Read one matching schema in `schemas/` and one matching JSON example in `examples/`. Read only those files. Fresh authorship means new stable IDs, domain wording, and layout; use the example for field shape, not facts. New workflow sources use `schema_version: 2` and its readable layout contract; keep `schema_version: 1` only when preserving an existing workflow's fixed geometry.
3. Artifact first: the next tool action must write the candidate. Write the candidate before inspecting renderer internals. Do not plan exact coordinates in prose. Start with one clear main path, short side branches, sparse labels, and at most 12 primary nodes. Set `meta.quality_profile` to `"showcase"` unless the user explicitly requests a dense `standard` map. Start with automatic routes and labels. Do not add `via`, `channelX`, `channelY`, or `labelAt` before a diagnostic calls for one; apply at most one diagnosed geometry control per repair.
4. Validate after every candidate edit and immediately before handoff:

   ```bash
   archmaster validate <type> <candidate.json> --quality showcase --json
   ```

   A receipt with only 4 artifact checks is basic validation, never showcase acceptance. A showcase pass must report all 9 artifact checks with 0 composition errors and 0 warnings. If the candidate omits or misspells the exact `meta.quality_profile` field, fix it before geometry. For a workflow v2 geometry diagnosis, run `archmaster validate workflow <candidate.json> --layout-json` and use the stable compiler receipt. A passing final validation freezes the candidate: never edit it afterward.
5. For a delivered HTML, `deliver` is the final acceptance command:

   ```bash
   archmaster deliver <type> <candidate.json> <output.html> --quality showcase --json
   ```

   A non-zero exit can never be described as success. A failed delivery preserves any previous output. If validation fails, change only the diagnosed `subject`, verify `evidence`, choose from `supportedFixes`, and rerun. Continue focused correction while the objective error count reaches a new minimum. If two consecutive rounds do not improve that best count, stop and report the unresolved diagnostics truthfully.

Workflow note: use schema v2 for new workflows; preserve schema v1 when an existing source needs fixed legacy geometry. Keep semantic edge labels and act on the compiler diagnostic.

Lifecycle note: phase columns `0..4` occupy the main rail; event/terminal column `N` in `0..2` aligns exactly beneath main column `N + 2`. A recoverable state uses `type: "failure"` plus a real transition back to the active state.

## Type router

| Type | Use for |
|---|---|
| `architecture` | Components, services, cloud/security boundaries, infrastructure |
| `workflow` | Processes, approval gates, tool calls, runbooks, CI/CD |
| `sequence` | API call chains, request lifecycles, async traces, returns |
| `dataflow` | Pipelines, ETL/ELT, lineage, governance, consumers |
| `lifecycle` | State/status transitions, retries, waiting and terminal states |

## Mermaid input

Read Mermaid for topology and meaning, then author fresh Archmaster JSON; do not mechanically render Mermaid styling.

- `flowchart` / `graph` → `workflow`, or `architecture` for a component map.
- `sequenceDiagram` → `sequence`; participants become semantic participants and arrows become messages.
- `stateDiagram` → `lifecycle`; states and transitions retain meaning, not Mermaid style.

## Authoring invariants

- One obvious main path; side branches leave the nearest main-path node. Remove low-value edges before adding routing controls.
- Omit `meta.visual_preset` by default so every diagram opens in `classic`, regardless of whether its resolved color mode is light or dark. Color mode and visual preset are independent: switching Light / Dark must preserve the current preset. Set `signal-flow`, `blueprint`, or `editorial` only when the user explicitly requests that visual style.
- Omit `meta.subtitle` by default. Never invent a subtitle that restates the title, nodes, or cards; include one short supporting line only when the user explicitly asks for it.
- Treat the standalone desktop viewer as a first-screen artifact by default, not a shallow strip. Generate one responsive artifact for laptops and external displays—never device-specific HTML or alternate topology. Start with enough authored vertical rhythm that the diagram panel and its conclusion cards occupy a balanced first screen; repair overflow by removing only genuinely redundant content or compacting spacing before shrinking nodes, labels, or the main panel. Never counterfeit a pass with `overflow: hidden`, clipped content, an internal diagram scroller, stretched SVG height, or smaller typography.
- Omit `meta.legend` for the truthful `auto` default. When needed, use only `mode: auto|all|hidden` and renderer-supported `entries.<kind>.label|visible`; labels never change semantics.
- Author in English. `meta.locale` accepts `"en"` only; the fixed Viewer UI and `<html lang>` are English.
- Preserve exact product names, code identifiers, commands, protocols, API paths, and environment names.
- Brand identity is not supported. Do not set a `brand` field on any node; the schema rejects it.
- For sequence diagrams, omit `meta.column_fit` for the stable `fixed` layout. Set it to `"spread"` when a wide viewBox would otherwise leave unused horizontal space or when meaningful participant labels do not fit the fixed boxes; do not shorten semantic labels before trying `spread`.
- Component types are `frontend`, `backend`, `database`, `cloud`, `security`, `messagebus`, and `external`; variants are `default`, `emphasis`, `security`, and `dashed`.
- Relationship labels are semantic data. When one collides, move the label, adjust the route or spacing, then shorten the wording while preserving meaning. Omit only wording that is already fully implied by both endpoints and contains no protocol, action, direction, synchronous/asynchronous behavior, or cross-boundary mechanism.
- Omit `meta.engineering_profile` by default. Enable `deployment-ownership` only when the user explicitly asks for a production deployment topology, ownership handoff, or fail-closed deployment review and the source facts are known. Once enabled, must not remove the engineering profile merely to pass validation; repair the facts or report the diagnostics truthfully.
- Spacing means clear gap, not center distance. For a relationship label, clear gap must exceed its measured mask width; follow the label-preserving repair order.
- Automatic routes own their endpoint sides. A side is a direction contract: the first and final segment must leave/enter perpendicular to that side.
- Never accept an edge crossing an unrelated opaque node, an ambiguous shared corridor, or a relationship label masking another route.

## Repository evidence

Architecture diagrams may ground nodes in real code. Set `meta.repository` to the GitHub URL plus a full 40-character commit SHA, and attach `sources` arrays to components. Validate with `--repo-root <path>` so archmaster verifies each reference against the checked-out repository at that revision before accepting the artifact. Never invent paths, line numbers, or revisions.

## Delivery

Use `validate` during repair and `deliver` once for final acceptance. Delivery freezes the exact specification bytes into a private same-directory snapshot, renders and checks that snapshot, atomically commits the HTML, and reports SHA-256 plus byte counts for both specification and artifact.

## Output

Return the checked HTML path, diagram type, validation summary, and specification/artifact receipt. Do not claim success for a non-zero command or claim visual inspection you did not perform.
