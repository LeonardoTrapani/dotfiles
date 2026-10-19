# Preparing a Discord release draft

## Destination and authorization

Use Computer Use when the user asks to prepare the message in their open Discord
app. Follow the current environment's browser/native-app routing and tool
documentation. In this session the destination was **Datapizza Space →
📢┊releases**; verify the current requested destination before writing.

"Prepara il messaggio" means populate an unsent composer and stage the requested
attachments. Sending requires an instruction to send. Preserve existing user
draft content: update the identified release draft, and clarify a conflict before
replacing unrelated text. Keep release copy separate from operational notes to
the user.

## UI workflow

1. Discover the running app and read its current state. Find the server, channel,
   and composer by observed names. Check the channel or thread identity on the
   composer itself; the window title alone is insufficient.
2. Paste the final text into that composer. Read the resulting UI state and
   verify the content and character counter. Avoid Return in a message composer
   while preparing a draft.
3. Use the observed upload menu to stage selected captures. A small dedicated
   local folder containing only the intended attachments simplifies selection.
   Verify each filename or preview in the draft after the chooser closes.
4. Recheck the destination, text, and all attachments. Leave the composer ready
   for review and report that it remains unsent. When sending was explicitly
   requested, verify the posted message and attachments after the final action.

## Native macOS file chooser

Use these recovery paths only when the observed UI exposes the corresponding
controls; read the active tool's documentation before using its API.

- A file chooser is a new sheet/window. Rebind or refresh the app state when
  accessibility indices or keyboard focus no longer match it.
- `Cmd+Shift+G` opens Go to Folder. Setting the observed `PathTextField` value
  avoids a clipboard timeout; Return there navigates the chooser, not the chat.
- A full file path can select the intended file directly. List view can expose
  filenames when column view hides them offscreen.
- In the observed chooser, ordinary clicks and Return sometimes left Open
  disabled despite a selected PNG. The file's exposed **Open Finder item**
  secondary action successfully returned that file to Discord as a staged
  attachment. Use it only when that exact action is present on the intended
  file; verify the resulting preview before continuing.

## Concurrent user activity

Refresh state immediately before an action after a "user changed app" error.
Batch an observation, its dependent action, and a fresh observation when useful.
Guard mutations with the currently observed destination. If the user moves to a
DM or another channel, do not paste or attach there. Preserve the saved release
draft, report what remains, and resolve persistent UI contention with the user
instead of repeatedly taking back their active conversation.
