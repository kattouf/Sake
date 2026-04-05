# Sake Workflow Skill Design

## Problem

When working on tasks in the Sake project, there is no structured process that ensures:
- Relevant project knowledge is loaded before starting work
- Quality checks and reviews happen consistently
- New knowledge discovered during work is captured back into the project's knowledge base (AGENTS.md, skills)

The knowledge base should grow organically as tasks are completed, making the agent more effective over time.

## Design

### Overview

A **checklist-style workflow skill** (`sake-workflow`) that creates a task list when invoked. Each step is a discrete task. The skill does not orchestrate or automate transitions — it provides structure, and the agent (or user) drives progression through steps.

Heavy interactive skills (brainstorming, writing-plans) are called explicitly at the appropriate step, not nested inside the workflow.

### Steps

#### 1. Discover Context

- Read the list of available skills, select relevant ones based on the task description
- Load selected skills (via Skill tool) to bring domain knowledge into context
- Read AGENTS.md for current project conventions and patterns

No fixed mapping of "task type -> skills". The agent decides relevance based on skill descriptions and task context.

#### 2. Brainstorm & Plan

- Invoke `superpowers:brainstorming` for design exploration
- After design approval — invoke `superpowers:writing-plans` for implementation plan

For trivial tasks (typo fix, single-line change, straightforward bug fix): skip this step. The agent judges triviality.

#### 3. Implement

- Execute the plan (invoke `superpowers:executing-plans` or work directly from the plan)
- Follow patterns and conventions from AGENTS.md and loaded skills

#### 4. Verify

- Run `sake format`
- Run `sake lint`
- Run tests (`sake test` or appropriate subset)
- On failure: fix and repeat until green
- This is a loop — do not proceed until all checks pass

#### 5. Review

Two sub-steps, in order:

**5a. Knowledge base conformance check**
Agent re-reads AGENTS.md and relevant skills, then reviews its own diff for:
- Violations of documented patterns and conventions
- Code style deviations not caught by automated tools
- Inconsistencies with existing codebase approaches

**5b. Quality code review**
Invoke `superpowers:requesting-code-review` for independent quality review:
- Correctness and edge cases
- Architecture and design quality
- Performance considerations

After both sub-steps: present results to the user, request feedback. If changes needed — return to step 3 or 4 depending on scope.

#### 6. Update Knowledge Base

**Trigger:** Only after step 4 (verify) passes. If review (step 5) caused rework, this step runs after the subsequent verify pass.

**Update criteria** — update if any of these discovered during work:
- Pattern or convention not described in AGENTS.md
- Project knowledge that had to be discovered and would be useful again
- Existing description in AGENTS.md or skills became inaccurate
- A domain or process worth capturing as a new skill (reference or procedural)

**What can be updated:**
- **AGENTS.md** — new patterns, conventions, architectural decisions
- **Existing skills** — corrections, improvements to workflow or reference skills
- **New skills** — reference skills (domain knowledge), process skills (repeated workflows), any type that serves as modular knowledge base for the agent

Use `superpowers:writing-skills` for creating or modifying skills.

If nothing qualifies — skip this step entirely.

#### 7. Commit

- Create commit with conventional commit message following project conventions (see AGENTS.md)
- Knowledge base updates (AGENTS.md, skills) are included in the same commit or a separate one, depending on logical grouping

### What the Skill Does NOT Do

- Does not automate transitions between steps (each step is a task, agent progresses manually)
- Does not duplicate logic of brainstorming/writing-plans/executing-plans — only specifies when to invoke them
- Does not require every step for every task — trivial tasks skip brainstorm/plan
- Does not prescribe which skills to load in step 1 — agent decides based on context

### Flow Diagram

```
Task received
    |
    v
[1. Discover context] -- load relevant skills, read AGENTS.md
    |
    v
[2. Brainstorm & Plan] -- brainstorming -> writing-plans (skip if trivial)
    |
    v
[3. Implement] -- executing-plans or direct implementation
    |
    v
[4. Verify] <-- loop: format, lint, test -> fix -> repeat
    |
    v
[5a. KB conformance check] -- diff vs AGENTS.md & skills
    |
    v
[5b. Quality review] -- superpowers:requesting-code-review
    |
    v
  User OK? --no--> back to [3] or [4]
    |
   yes
    v
[6. Update knowledge base] -- AGENTS.md, skills (if applicable)
    |
    v
[7. Commit]
```
