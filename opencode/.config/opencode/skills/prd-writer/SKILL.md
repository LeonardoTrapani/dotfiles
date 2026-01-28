---
name: prd-writer
description: Create PRDs for Ralph autonomous execution. Use when planning features, starting projects, or asked to create/write a PRD. Triggers on: create prd, write prd, plan feature, ralph prd, tasks/prd.
---

# PRD Writer for Ralph

Create PRDs that Ralph can execute autonomously, one task at a time.

## The Job

1. Receive feature description
2. Ask clarifying questions when ANY doubt exists (use lettered options)
3. Generate structured PRD in `tasks/prd.jsonc`

**Do NOT implement. Only create the PRD.**

---

## Clarifying Questions

Ask when you have ANY doubt. Focus on:

- **Problem/Goal**: What problem does this solve?
- **Core Functionality**: What are the key actions?
- **Scope**: What should it NOT do?
- **Verification**: How do we know it works?

Format with lettered options for quick answers:

```
1. What's the primary goal?
   A. Improve onboarding
   B. Increase retention
   C. Reduce support burden

2. Target scope?
   A. Minimal viable
   B. Full-featured
   C. Backend only
   D. UI only
```

User can respond "1A, 2C" for speed.

---

## Output Format

```jsonc
{
  "project": "[Project Name]",
  "description": "[What this PRD accomplishes]",
  "tasks": [
    {
      "title": "[Short task name]",
      "steps": ["First thing to do", "Second thing to do", "Third thing to do"],
      "verify": [
        "This condition is true",
        "This check passes",
        "Typecheck passes",
      ],
      "passes": false,
    },
  ],
}
```

### Fields

- **steps**: HOW to complete the task. Concrete actions.
- **verify**: Conditions that MUST be true when done. Verifiable checks.
- **passes**: Always `false` initially. Ralph sets to `true` when complete.

---

## Task Size: The Critical Rule

Each task must be completable in ONE Ralph iteration (one context window).

Ralph spawns fresh per iteration with no memory. If a task is too big, it runs out of context and produces broken code.

### Right-sized tasks:

- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):

- "Build the dashboard" → split into: schema, queries, components, filters
- "Add authentication" → split into: schema, middleware, login UI, session
- "Refactor the API" → one task per endpoint

---

## Steps: Be Concrete

Steps tell Ralph HOW to do the work. Be specific.

### Good steps:

- "Add `status` column to tasks table with type enum('pending', 'done')"
- "Create StatusBadge component in src/components/"
- "Update TaskCard to render StatusBadge based on task.status"
- "Add filter dropdown to TaskList header with options: All, Pending, Done"

### Bad steps:

- "Implement the feature"
- "Make it work"
- "Add necessary changes"

---

## Verify: Mandatory & Checkable

**Verification is not optional.** Ralph must actually run/check each verify item. If it can't verify, it either ABORTs or leaves the task incomplete.

Every verify item must be something Ralph can execute and get a pass/fail result.

### Verification by task type:

**All tasks:**

- `"Typecheck passes"` - always required

**UI/Frontend tasks:**

- `"Verify in browser using agent-browser skill"` - MANDATORY, no exceptions
- Check specific elements render, interactions work, styles apply

**API/Backend tasks:**

- `"API returns expected response"` - test with actual request
- `"curl/httpie returns 200 with correct body"`
- `"Database query returns expected rows"`

**CLI tasks:**

- `"Running [command] outputs [expected]"`
- `"Exit code is 0"`
- `"Help text shows new option"`

**Logic/Service tasks:**

- `"Tests pass"` - write and run actual tests
- `"Function returns [X] for input [Y]"`

### Bad verify (vague, uncheckable):

- "Works correctly"
- "Good UX"
- "Handles edge cases"
- "Is performant"

### Example verify items:

```jsonc
// UI task
"verify": [
  "Button appears in header",
  "Clicking button opens modal",
  "Modal shows user data",
  "Typecheck passes",
  "Verify in browser using agent-browser skill"
]

// API task
"verify": [
  "GET /api/users returns array of users",
  "POST /api/users creates user and returns 201",
  "Invalid input returns 400 with error message",
  "Typecheck passes",
  "Tests pass"
]

// CLI task
"verify": [
  "Running 'mycli --help' shows new flag",
  "Running 'mycli generate' creates expected file",
  "Exit code is 0 on success, 1 on error",
  "Typecheck passes"
]
```

---

## Example

**Input**: "Add task priority system - high/medium/low with filtering"

**Output** `tasks/prd.jsonc`:

```jsonc
{
  "project": "TaskApp",
  "description": "Task priority system with visual indicators and filtering",
  "tasks": [
    {
      "title": "Add priority field to database",
      "steps": [
        "Add priority column to tasks table: enum('high', 'medium', 'low') default 'medium'",
        "Generate migration",
        "Run migration",
      ],
      "verify": [
        "Tasks table has priority column",
        "New tasks default to 'medium' priority",
        "Typecheck passes",
      ],
      "passes": false,
    },
    {
      "title": "Display priority badge on task cards",
      "steps": [
        "Create PriorityBadge component with color variants (red=high, yellow=medium, gray=low)",
        "Add PriorityBadge to TaskCard component",
        "Style badge to be visible without hover",
      ],
      "verify": [
        "Each task card shows colored priority badge",
        "Colors match: red=high, yellow=medium, gray=low",
        "Typecheck passes",
        "Verify in browser using agent-browser skill",
      ],
      "passes": false,
    },
    {
      "title": "Add priority selector to task edit",
      "steps": [
        "Add priority dropdown to task edit modal",
        "Wire dropdown to update task priority on change",
        "Show current priority as selected value",
      ],
      "verify": [
        "Priority dropdown appears in edit modal",
        "Changing priority saves immediately",
        "UI updates without page refresh",
        "Typecheck passes",
        "Verify in browser using agent-browser skill",
      ],
      "passes": false,
    },
    {
      "title": "Filter tasks by priority",
      "steps": [
        "Add filter dropdown to task list header with options: All, High, Medium, Low",
        "Implement filter logic to show only matching tasks",
        "Persist filter state in URL params",
      ],
      "verify": [
        "Filter dropdown has all options",
        "Selecting filter shows only matching tasks",
        "Filter persists on page reload via URL",
        "Typecheck passes",
        "Verify in browser using agent-browser skill",
      ],
      "passes": false,
    },
  ],
}
```

---

## Checklist Before Saving

- [ ] Asked questions when ANY doubt existed
- [ ] Each task completable in one iteration
- [ ] Steps are concrete actions, not vague
- [ ] Verify items are executable pass/fail checks
- [ ] Every task has "Typecheck passes"
- [ ] UI tasks have "Verify in browser using agent-browser skill
- [ ] Saved to `tasks/prd.jsonc`
