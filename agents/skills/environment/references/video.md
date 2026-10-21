# Video

A proof video is a short motion piece the user wants to watch; use a raw recording
only for one action under ten seconds. Storyboard first: per chapter, the claim,
focal element, input and payoff; two to four chapters, 15–35 seconds, one dataset.
Open on the real subject with its value visible within three seconds and end on
the verified outcome, held for at least two seconds. Land the camera on each input
before it happens and hold still while the change happens. Keep meaningful actions
at real speed and label accelerated footage. Use one caption per chapter, a benefit
in at most six words; frames must read at 390 px wide without zoom.

## Capture

Use the harness's browser recording tools for web apps. For native apps, open the
simulator through its device tools and use the recording launcher and flags they
return. Capture the real input through its observable outcome, including relevant
failure paths. Use representative data and the app's supported viewport and theme.
Wait for an observable condition before recording; omit loading frames and idle time.

For browser camera targets, inspect the actual element and read its box through
the harness's page-evaluate tool (`preview_evaluate` in T3) right after recording
starts and before each input. Record the
input target and outcome's box with their timestamps:

```js
(() => {
  const r = document.querySelector('<selector>').getBoundingClientRect()
  // Fractions of the recording after its crop to multiples of 16.
  const w = Math.floor(innerWidth / 16) * 16
  const h = Math.floor(innerHeight / 16) * 16
  const box = [r.left / w, r.top / h, r.width / w, r.height / h]
  return {box, t: Date.now(), target: [box[0] + box[2] / 2, box[1] + box[3] / 2]}
})()
```

For simulator footage, take target positions from the device's observed bounds
and map them to recording coordinates.

## Compose

Work in a scratch HyperFrames project outside the repository. Use portrait for a
phone recording and landscape only for a layout that exists only on desktop.
Re-encode recordings as below: a side that is not a multiple of 16 renders a black
strip. Put the app's font in `assets/`. `npx hyperframes@0.8.141 docs <topic>` holds
the composition contract. Disable telemetry and skill installation; keep rendering
local and do not run HyperFrames feedback, publish or cloud commands. Use an
available local Chromium; set `HYPERFRAMES_BROWSER_PATH` only to its verified path
if the renderer needs it.

Every video uses the app's font, primary color and radius:

- **Layout.** On the app's foreground hue darkened to near black, top to bottom:
  progress, caption, then recording in a frame with the app's radius. Use margins
  of 6% and a caption size of 5% of the short side. Only the touch marker and reveal
  cover the recording; keep captions outside it.
- **Progress.** One 6 px segment per chapter, filling with the primary over its chapter.
- **Captions.** Weight 650; words rise into focus one after another (blur 12 px to
  zero, 0.45 s, 0.035 s stagger) and leave before the next caption.
- **Camera.** Portrait fills the frame's width, shows about four fifths of the
  screen's height and pans to each input, since a push crops rows. Landscape pushes
  frames meant to be read in to at most 500 CSS px of the app's width. Use Expo
  easing; each move takes 0.25–0.65 s and settles 0.2 s before its input.
- **Touch.** A white marker 38 app CSS px wide, scaled with the recording, at 55%
  opacity with a 3 px white border and primary ring, enters in 0.22 s, presses to
  0.78 in 0.08 s while a 0.55 s primary ripple beneath it grows to 2.6×, and fades
  in 0.25 s.
- **Chapters.** Start 0.6 s before the previous one ends and grow out of its last
  input as a circular clip; dim the previous view to brightness 0.55 at 0.96 scale.
- **Reveal.** Zoom onto the verified outcome, at most 2.6×, inside a 4 px primary
  outline offset 6 px, with everything else dimmed to 80% backdrop. Enter in 0.5 s
  and hold to the end. Energy rises only around this one reveal.

HyperFrames pitfalls: a `fromTo` that starts later needs `immediateRender: false`,
or its start state appears from frame one. A filter tween must state its start,
`brightness(1)`, or GSAP starts at zero and flashes black. Select by id: the bundler
cannot parse a selector built from a template literal. A camera container taller
than the stage needs `data-layout-allow-overflow`. Put a timed video in untimed
wrappers, which `check` otherwise rejects as `video_nested_in_timed_element`.

In the commands below, `<claim>` is a short slug naming the demonstrated claim.

```bash
export HYPERFRAMES_NO_TELEMETRY=1 HYPERFRAMES_SKIP_SKILLS=1
npx hyperframes@0.8.141 init <claim> --example blank --resolution portrait --non-interactive
mkdir <claim>/assets
ffmpeg -i <recording> -vf 'crop=trunc(iw/16)*16:trunc(ih/16)*16:0:0' -r 30 -force_key_frames 'expr:gte(t,n_forced)' -c:v libx264 -pix_fmt yuv420p <claim>/assets/chapter-<n>.mp4
# Inside <claim>/, after composing:
npx hyperframes@0.8.141 check
npx hyperframes@0.8.141 render --quality delivery --output <claim>.mp4
```

## Verify

Inspect every chapter's frame at phone size and a contact sheet of the whole video.
Check camera landings, readable captions, touch timing and the held final outcome.
Editing must preserve the real action and result; label any time compression.
Keep credentials and private identities out of the published derivative.

```bash
ffmpeg -ss <second> -i <claim>.mp4 -frames:v 1 -vf scale=390:-1 <frame>.png
ffmpeg -i <claim>.mp4 -vf fps=1,scale=640:-1,tile=4x4 <sheet-%03d.png>
```

Adapted from [deslop's video reference](https://github.com/MP281X/deslop/blob/main/.claude/skills/environment/references/video.md).
