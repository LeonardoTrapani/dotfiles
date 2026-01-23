---
description: Convert PRDs to Ralph's JSON format
---

Converts existing PRDs to tasks/prd.jsonc format that Ralph uses for autonomous execution.

## Output Format

```jsonc
{
  "project": "[Project Name]",
  "description": "[Feature description from PRD title/intro]",
  "userStories": [
    {
      "title": "[Story title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": ["Criterion 1", "Criterion 2", "Typecheck passes"],
      "passes": false,
      "notes": "",
    },
  ],
}
```

## Story Size: The Number One Rule

Each story must be completable in ONE Ralph iteration (one context window).

Ralph spawns a fresh instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories:

- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):

- "Build the entire dashboard" → split into: schema, queries, UI components, filters
- "Add authentication" → split into: schema, middleware, login UI, session handling
- "Refactor the API" → split into one story per endpoint or pattern

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it's too big.

## Acceptance Criteria: Must Be Verifiable

Each criterion must be something Ralph can CHECK, not something vague.

### Good criteria (verifiable):

- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"
- "Typecheck passes"
- "Tests pass"

### Bad criteria (vague):

- "Works correctly"
- "User can do X easily"
- "Good UX"
- "Handles edge cases"

### Always include as final criterion:

```
"Typecheck passes"
```

For stories with testable logic:

```
"Tests pass"
```

For stories that change UI:

```
"Verify in browser using agent-browser skill"
```

## Conversion Rules

1. Each user story becomes one JSON entry
2. All stories: `passes: false` and empty `notes`
3. Always add: "Typecheck passes" to every story's acceptance criteria

Note: No priority field needed - Ralph determines execution order based on dependencies.

## Splitting Large Stories

If a PRD has big features, split them:

**Original:**

> "Add user notification system"

**Split into:**

1. US-001: Add notifications table to database
2. US-002: Create notification service for sending notifications
3. US-003: Add notification bell icon to header
4. US-004: Create notification dropdown panel
5. US-005: Add mark-as-read functionality
6. US-006: Add notification preferences page

Each is one focused change that can be completed and verified independently.

## Example

**Input PRD:**

```markdown
# Task Status Feature

Add ability to mark tasks with different statuses.

## Requirements

- Toggle between pending/in-progress/done on task list
- Filter list by status
- Show status badge on each task
- Persist status in database
```

**Output tasks/prd.jsonc:**

```jsonc
{
  "project": "TaskApp",
  "description": "Task Status Feature - Track task progress with status indicators",
  "userStories": [
    {
      "title": "Add status field to tasks table",
      "description": "As a developer, I need to store task status in the database.",
      "acceptanceCriteria": [
        "Add status column: 'pending' | 'in_progress' | 'done' (default 'pending')",
        "Generate and run migration successfully",
        "Typecheck passes",
      ],
      "passes": false,
      "notes": "",
    },
    {
      "title": "Display status badge on task cards",
      "description": "As a user, I want to see task status at a glance.",
      "acceptanceCriteria": [
        "Each task card shows colored status badge",
        "Badge colors: gray=pending, blue=in_progress, green=done",
        "Typecheck passes",
        "Verify in browser using agent-browser skill",
      ],
      "passes": false,
      "notes": "",
    },
    {
      "title": "Add status toggle to task list rows",
      "description": "As a user, I want to change task status directly from the list.",
      "acceptanceCriteria": [
        "Each row has status dropdown or toggle",
        "Changing status saves immediately",
        "UI updates without page refresh",
        "Typecheck passes",
        "Verify in browser using agent-browser skill",
      ],
      "passes": false,
      "notes": "",
    },
    {
      "title": "Filter tasks by status",
      "description": "As a user, I want to filter the list to see only certain statuses.",
      "acceptanceCriteria": [
        "Filter dropdown: All | Pending | In Progress | Done",
        "Filter persists in URL params",
        "Typecheck passes",
        "Verify in browser using agent-browser skill",
      ],
      "passes": false,
      "notes": "",
    },
  ],
}
```

## Checklist Before Saving

Before writing prd.jsonc, verify:

- [ ] Each story is completable in one iteration (small enough)
- [ ] Every story has "Typecheck passes" as criterion
- [ ] UI stories have "Verify in browser using agent-browser skill" as criterion
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No story depends on a later story
