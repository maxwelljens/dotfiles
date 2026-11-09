---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, then implement improvements.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**:
refactors that turn shallow modules into deep ones. The aim is testability and
AI-navigability.

This command should be _informed_ by the project's domain model and built on
a shared design vocabulary.

## Process

**Scope before you scan: YAGNI.** Deepening a module pays off by making future
changes to it easier, so put extra weight on the parts of the codebase that
have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it,
  and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log
  --oneline`) to find the codebase's hot spots, the files and areas that keep
  coming up, and let those paths pull your attention first. If the changes are
  scattered with no clear hot spot, widen the net.

Read the project's domain glossary (e.g. `CONTEXT.md`) and any ADRs in the area
you're touching first.

Then spawn a sub-agent to walk the codebase. Don't follow rigid heuristics;
explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small
  modules?
- Where are modules **shallow**, with an interface nearly as complex as the
  implementation?
- Where have pure functions been extracted just for testability, but the real
  bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their
  current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting
it concentrate complexity, or just move it? A "yes, concentrates" is the signal
you want.

**Use CONTEXT.md vocabulary for the domain.** If `CONTEXT.md` defines "Order,"
talk about "the Order intake module," not "the FooBarHandler," and not "the
Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it
when the friction is real enough to warrant revisiting the ADR. Mark it clearly
in the card (e.g. a warning callout: _"contradicts ADR-0007, but worth
reopening because…"_). Don't list every theoretical refactor an ADR forbids.

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the
  term to `CONTEXT.md`. Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md`
  right there.
