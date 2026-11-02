When something is easier to see than to read (a flow, a comparison, a plan, a structure), show it as an `html_render` page.

## The last message of a turn

I read only the last message of each turn, so it has to stand on its own.

- Wait for everything you started (commands, builds, checks, subagents, delegates) before you end the turn; in T3 use `t3_background_wait`. Never end on "waiting for X", "when it finishes I'll Y" or "running Z now": wait, then report the result. If you really can't wait (a pipeline the host will wake you for, a step that needs me), say exactly what is still running and what wakes you.
- Write it as if I saw nothing else from this turn: what you did and found, the results, every open question and what I need to do. Repeat whatever still matters from earlier in the turn. Never point back with "see above" or "my previous message".
- Number open questions, each with your recommendation, and repeat any question I haven't answered yet.
- Send no progress updates during the turn. A turn woken by a background event (a pipeline, a delegate, a timer) is not a progress tick: either finish the next step and report the whole current state, or stay silent.
