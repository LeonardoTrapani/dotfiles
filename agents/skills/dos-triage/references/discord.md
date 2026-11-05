# Discord forums via the Dual MCP

The Discord bot connection lives in the Dual team **Dual OS**, not in the default
Datapizza team. Read the active context with `dual_context get`, switch with
`dual_context set` (organization `Datapizza`, team `Dual OS`), and switch back to
the original team when the phase ends.

## IDs

- Guild: `1112370739656536126`
- `🆘┊bugs`: `1525120450051571753`
- `🆕┊questions-and-feature-requests`: `1528319637287079997`
- Bot user (Dual OS Bot): `1546539250546122922`

Tags (the same names in both forums, with different IDs):

| Tag         | bugs                  | questions-and-feature-requests |
| ----------- | --------------------- | ------------------------------ |
| Open        | `1525178173959176353` | `1532735087764836563`          |
| Noted       | `1529047974561320990` | `1529048293848383568`          |
| In progress | `1532734319821586482` | `1532735270552604762`          |
| Done        | `1525178188689444947` | `1529048332281053264`          |
| Cancelled   | `1556337329256276069` | `1529048218720145418`          |

If an ID stops resolving, list the forums again with
`discord-api.guilds.list-guild-channels({ guild_id })` (type 15 = forum, `available_tags`).
`discord-api.users.list-my-guilds` fails with `SchemaError`; do not rely on it.

## Fetch every open post

A post is open when it has neither the Done nor the Cancelled tag. Archived threads
count too. Run this with `mcp__dual__execute`; it returns compact rows only.

```ts
const guild_id = "1112370739656536126";
const forums = { "1525120450051571753": "bugs", "1528319637287079997": "qfr" };
const tag = {
  "1525178173959176353": "Open", "1525178188689444947": "Done", "1529047974561320990": "Noted",
  "1532734319821586482": "In progress", "1556337329256276069": "Cancelled",
  "1532735087764836563": "Open", "1529048332281053264": "Done", "1529048293848383568": "Noted",
  "1532735270552604762": "In progress", "1529048218720145418": "Cancelled",
};
const threads = [];
const active = await tools["discord-api.guilds.get-active-guild-threads"]({ guild_id });
for (const t of active.threads ?? []) if (forums[t.parent_id]) threads.push(t);
for (const channel_id of Object.keys(forums)) {
  let before;
  for (let i = 0; i < 10; i++) {
    const page = await tools["discord-api.channels.list-public-archived-threads"]({ channel_id, limit: 100, ...(before ? { before } : {}) });
    threads.push(...(page.threads ?? []));
    if (!page.has_more || !page.threads?.length) break;
    before = page.threads.at(-1).thread_metadata.archive_timestamp;
  }
}
const rows = threads.map((t) => ({
  id: t.id, forum: forums[t.parent_id], name: t.name,
  tags: (t.applied_tags ?? []).map((x) => tag[x] ?? x),
  archived: !!t.thread_metadata?.archived, created: t.thread_metadata?.create_timestamp?.slice(0, 10),
  messages: t.message_count,
}));
const open = rows.filter((r) => !r.tags.includes("Done") && !r.tags.includes("Cancelled"));
// Discord rate-limits globally (429) and the sandbox has no timers: small batches, retry.
const messages = async (channel_id) => {
  for (let attempt = 0; ; attempt++) {
    try { return await tools["discord-api.channels.list-messages"]({ channel_id, limit: 100 }); }
    catch (e) { if (attempt >= 5 || !String(e.message).includes("429")) throw e; }
  }
};
for (let i = 0; i < open.length; i += 5) await Promise.all(open.slice(i, i + 5).map(async (r) => {
  const ms = (await messages(r.id)).sort((a, b) => (a.id < b.id ? -1 : 1));
  const first = ms[0], last = ms.at(-1);
  r.author = first?.author?.global_name ?? first?.author?.username;
  r.body = (first?.content ?? "").replace(/\s+/g, " ").slice(0, 240);
  r.lastAt = last?.timestamp?.slice(0, 10);
  r.lastBy = last?.author?.global_name ?? last?.author?.username;
  r.dos = [...new Set(ms.map((m) => m.content ?? "").join("\n").match(/DOS-\d+/g) ?? [])];
}));
return { total: rows.length, open };
```

The DOS keys usually come from Dual OS Bot replies: the intake workflow
"DOS — Discord → Jira intake — Team" creates or updates the ticket when Team
Product mentions the bot in a post.

For a single post in detail, read all its messages with
`discord-api.channels.list-messages({ channel_id: <post id>, limit: 100 })` and
follow `before` for longer threads. Post link: `https://discord.com/channels/1112370739656536126/<post id>`.

## Change a post's tags

Threads are channels: `discord-api.channels.update-channel({ channel_id, payload: { applied_tags } })`.
Read the input type with `tools.describe.tool` first and send the post's full new
tag list (it replaces the old one). Use the tag IDs of the post's own forum.
