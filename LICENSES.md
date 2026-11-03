# Third-party components

Bundled:
- three.js + addons (MIT) — `styles/red-ghost/example/vendor`, `styles/sunlit-explainer/example/vendor`.
- Fonts, all from Google Fonts: Permanent Marker, Arimo (Apache License 2.0); Patrick Hand, Patrick Hand SC,
  Gochi Hand, Kalam, Caveat, Barlow Condensed, Anton, Arvo (SIL Open Font License 1.1).
  Red Ghost captions use the computer's own Arial Bold when it has one (Mac, Windows), else Arimo; Sunlit printed
  type uses the computer's own Rockwell when it has one (Mac), else Arvo. Neither Arial nor Rockwell is bundled.
- Example music: `styles/lamplit-ink/example/audio/music.mp3` and `styles/sunlit-explainer/example/audio/music.mp3`
  were made locally with ACE-Step 1.5 (MIT) by the skill's author; free to use in your own videos.
- Example narrations were made with Kokoro-82M (Apache-2.0). The stories, drawings, 3D sets, characters, sound design
  and code are original and free to use, remix and share.

Installed on first use (not bundled):
- Kokoro-82M (Apache-2.0) via kokoro-onnx (MIT) — local text-to-speech voices.
- faster-whisper (MIT) + Whisper small.en (MIT) — word timestamps.
- numpy, scipy, soundfile — audio processing.
- ACE-Step 1.5 (MIT) — optional local music.
