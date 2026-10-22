# Videos

Make every video with [Psychopomp](https://github.com/kitlangton/psychopomp),
checked out at `~/dev/psychopomp`. Pull it first, then work inside it and follow
its `psychopomp` and `explainer-motion` skills in `.agents/skills`. It needs a
recent Rust toolchain, the GPU, FFmpeg with `libx264` and Bun. `cargo` lives in
`~/.cargo/bin`, which agent shells may not have on `PATH`.

## Narration

Voice narration with ElevenLabs. The key is the `credential` field of the
"Elevenalbs personal API Credentials" item in the Personal vault of 1Password.
Read it in the same command that uses it:

```sh
ELEVENLABS_API_KEY="$(op read 'op://Personal/qmw6fkw67intohikok2b65u6yq/credential')" \
  bun scripts/narrate.ts scenes/<name>/narration/script.json
```

The same prefix works for `cargo run -p <crate>` when the Scene Program declares
its narration with `psychopomp-media`. Draft with `--draft` or
`PSYCHOPOMP_MEDIA=draft` until the script is settled, and check the cost with
`PSYCHOPOMP_MEDIA=plan` before generating. If 1Password is unavailable, ship the
draft voice and say so.

## Recordings

A proof video shows the real implementation, not an animation of it. Delegate the
capture to a Codex subagent with browser/computer use in a fresh isolated session.
Give it the app or preview URL, the input-to-outcome journey to demonstrate,
representative data, viewport and theme, and the evidence you need. Follow the
repository's capture requirements.

Ask the subagent to capture the real interaction and export the clip. Completion
means it has opened the exported file, checked that the meaningful input and
expected result are visible, and returned the local artifact path with what the
recording proves and any limitations.

Bring the clip into a Psychopomp scene as footage (see `scenes/footage`) and add
the framing around it: captions, callouts, narration. Keep the captured
interaction uncut so it still proves the claim.

Review the rendered video before publishing it under its claim in the PR. If the
subagent cannot record or export, report the missing capability and provide the
strongest available evidence without claiming a recording was made.
