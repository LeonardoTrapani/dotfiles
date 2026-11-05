# Leonardo's release-message style

## Voice and audience

Write in Italian, for colleagues using or building with the product. Use familiar
terms such as workflow, agenti, plugins, connections, Architect, and MCP when
appropriate. Prefer direct explanations of what someone can now do, a short
example, and the entry point needed to try it.

Use a concrete title and brief paragraphs. Feature subsections and parallel lists
are useful when several changes ship together. Keep enthusiasm natural, with
little promotional language and few emoji. Do not reproduce spelling mistakes
from examples as a stylistic requirement.

Technical changes earn space through their consequence: more available actions,
easier setup, preserved workflows, usable long conversations, or clearer errors.
Reserve SDK details for a developer-facing section when the audience needs them.
Avoid dumping package versions and implementation internals into the main post.

## Shape

1. Title naming the main capability or group of changes.
2. One short opening, if useful, stating what is changing.
3. Main feature: capability, practical effect, example, relevant screenshot.
4. Other major features in descending importance.
5. Short list of remaining useful improvements, when warranted.
6. Practical compatibility or setup note where it affects usage.
7. Link to the complete changelog for the stated scope.
8. Natural invitation to try it or report problems.

This is an editorial shape, not a mandatory number of sections. A small release
may need only one paragraph. Give the main feature proportionally more space.

## Examples of phrasing

The following excerpts are voice references from Leonardo's supplied messages,
not claims about the current release:

> Ora si può accedere a DualOS e tutti i tool connessi da qualunque harness.
> Questo vuol dire che, per esempio, da ChatGPT si può chiedere cosa si ha da
> fare su Jira, creare workflow, runnare workflow, schedulare agenti...

> Su questo link (o cliccando l'icona del libro) si trovano tutte le docs
> funzionali di DualOS. Servirà iterazione, ma almeno abbiamo un posto ufficiale.

Useful endings: "Dateci un occhio!" or "Se avete problemi scrivete!"

## Evidence and length

Keep examples specific to verified behavior. A screenshot can carry interface
detail that would otherwise lengthen the text. Use only media that illustrates
the selected story; do not fill an attachment quota.

For Discord, inspect the account's actual composer limit. A 2,000-character
limit was observed in this workflow. Count the final text, then verify the UI
counter. Trim secondary detail first. If the requested detail needs multiple
posts, prepare a coherent sequence rather than silently turning the message
into a text-file attachment or dropping a major feature.
