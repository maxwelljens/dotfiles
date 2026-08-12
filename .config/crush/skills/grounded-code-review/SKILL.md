---
name: grounded-code-review
description: Apply a lens-based inspection and counterfactual verification when the user requests a code review or optimization.
---

# Grounded Code Review

This skill executes a highly accurate code review by structuring the agent's reasoning to overcome inherent language model biases — specifically the tendency to over-correct and hallucinate requirement violations. It achieves this through isolated **lens** inspections and **counterfactual** verification.

## Steps

Follow these steps in exact order. Complete the current step's **completion criterion** before advancing to the next.

1. **Ground the Intent**
   Locate the explicit natural language problem description or feature requirement the code intends to solve. If absent, ask the user for it before proceeding. Code correctness classification relies heavily on the presence of problem descriptions.
   *Completion Criterion:* A single sentence summarizing the exact problem description is written in your scratchpad.

2. **Apply the Lenses**
   Analyze the code by adopting three distinct **lenses** sequentially. Keep the findings of each perspective strictly separated.
   - *Correctness Lens*: Focus exclusively on logic errors and boundary condition failures.
   - *Maintainability Lens*: Focus exclusively on code smells, readability, and structural technical debt.
   - *Optimization Lens*: Focus exclusively on performance and resource utilization.
   *Completion Criterion:* A list of raw findings is produced, where every finding is tagged with its source **lens** and linked to a specific code line number.

3. **Perform Counterfactual Verification**
   Run a fix-guided verification filter on every raw finding to prevent systematic false negatives. For each finding, generate the proposed fix. Treat this fix as **counterfactual** evidence: evaluate whether the original implementation actually fails the natural language requirement established in Step 1 compared to the fix. Discard the finding if the original code safely satisfies the requirement.
   *Completion Criterion:* Every raw finding is explicitly marked as 'validated' or 'discarded' based on the **counterfactual** test.

4. **Apply Persistent Rules**
   Consult the accumulated behavioral rules via the context pointer `REVIEW_RULES.md`. Evaluate the code against these historical standards to achieve a zero recurrence rate for past error classes.
   *Completion Criterion:* Every rule in the persistent checklist is marked as 'passed' or 'flagged'.

5. **Synthesize the Final Review**
   Present the final review document to the user. Include only the findings marked as 'validated' in Step 3 and 'flagged' in Step 4. 
   *Completion Criterion:* The generated output contains zero discarded findings and presents actionable fixes for the validated ones.

## Reference

### Lens
A focused analytical perspective that forces the agent to assess one dimension of the code at a time. Segmenting review tasks into distinct roles produces more consistent and meaningful outcomes than holistic reading. 

### Counterfactual
A proposed fix treated as a baseline to test the validity of a detected flaw. Large language models exhibit a systematic failure mode of misjudging correct code as failing to meet requirements. By formulating a fix and explicitly testing if the *original* code fails the requirement relative to the fix, you force a rigorous necessity check that filters out hallucinated issues.

### Persistent Rules Context Pointer
If the file `REVIEW_RULES.md` exists in the workspace, read it. It contains a checklist of accumulated behavioral rules derived from previous human review feedback, serving as a closed-loop framework for persistent cross-session learning. If it does not exist, proceed without it.
