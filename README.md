# faceless-videos — a free Claude Code skill

Narrated faceless videos in three ready styles, everything drawn or built in code on your own computer:

1. **Lamplit Ink**: a hand-inked cartoon survival story in 9:16, run as a "Part 1" series with real numbers on cream cards and a cliffhanger.
2. **Red Ghost**: a ~30 s crime-reconstruction horror short. Glowing ember-red faceless people move through a dim 3D room, with yellow captions and a whispered phone voice. 9:16 + 16:9.
3. **Sunlit Explainer**: a ~30 s 3D history explainer with stylized skinned humans in low warm sun, fast cuts and the music drop on the reveal. 16:9.

Cost: $0. It uses a local Kokoro voice, local Whisper for word timings, three.js/canvas for the pictures, numpy for
the sound, and headless Chrome + ffmpeg for the render. There is no AI image or video generation and no API keys.
Original music made locally with ACE-Step is optional.

Install: unzip into `~/.claude/skills/faceless-videos/`, run `bash scripts/setup.sh` (prints "All set"), then
`bash scripts/selftest.sh` (prints "SELFTEST PASSED"). After that, ask Claude Code for a faceless video in any session.

Layout: `SKILL.md` (what Claude follows) · `scripts/` (setup, selftest, new_video, voice, words, music) ·
`styles/<style>/STYLE.md` + `style-sheet.jpg` + `example/` (a complete project that renders as-is).
