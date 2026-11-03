---
name: faceless-videos
description: Make narrated faceless videos for YouTube, TikTok, Reels and Shorts in three ready styles, all drawn or built in code on the user's own computer with a local AI voice — no image/video generation, $0. (1) Lamplit Ink: a hand-inked cartoon survival / what-would-you-do story in 9:16 ("Part 1" series, beanie stick-figure hero, cream data cards with real numbers, a creepy thread, a cliffhanger). (2) Red Ghost: a ~30 s crime-reconstruction horror short, glowing ember-red faceless people in a dim 3D room, yellow captions, a whispered phone voice (9:16 + 16:9). (3) Sunlit Explainer: a ~30 s Zack D. Films–style 3D explainer, stylized humans in low warm sun, fast cuts, how something was invented or works (16:9). Use whenever someone wants a faceless video or channel, a narrated story video, a survival story cartoon, a horror or true-crime short, a 3D history/invention explainer, or a video like beaniesurvives, enthyme or Zack D. Films — even if they only give a topic.
---

# Faceless Videos

Three faceless styles, each a working film engine with an example you can study and re-render. **You do the work:
the user picks a style and a topic, approves one plan, and gets a finished MP4 with voice, music and sound.**
`SKILL` = the folder this file is in. Projects live in `~/faceless-videos/<short-name>/`.

| style | what it makes | default length · aspect | read |
|---|---|---|---|
| **Lamplit Ink** `lamplit-ink` | a hand-inked cartoon story: stick hero in a mustard beanie, amber lamplight, midnight glass; "PART 1" header, the panel on a blurred copy of itself, cream data cards with real numbers; calm second-person narrator, an escalating creepy thread, a cliffhanger | 1–3 min · 9:16 | `styles/lamplit-ink/STYLE.md` |
| **Red Ghost** `red-ghost` | a crime / horror reconstruction: faceless people made of glowing ember-red light in a dim, real-looking 3D room; yellow one-line captions, cream date stamp, "Ring!"/"Knock." words; calm narrator + whispered phone voice; a twist at the end | ~30 s · 9:16 and 16:9 | `styles/red-ghost/STYLE.md` |
| **Sunlit Explainer** `sunlit-explainer` | a fast 3D explainer: stylized skinned humans mid-task in low warm sun, type only printed on objects, one blurred foreground element per frame; true story of how something came to be, the music drop on the reveal | ~30 s · 16:9 | `styles/sunlit-explainer/STYLE.md` |

Everything is local and free: Kokoro voice, Whisper word timings, three.js / canvas drawing, numpy sound, Chrome
headless capture, ffmpeg. No image or video generation, no API keys. Optional original music with ACE-Step (local).

## 0. First use on a machine
`bash SKILL/scripts/setup.sh` until it prints **All set** (checks Node 22+, ffmpeg, Chrome, uv; builds the private
Python env in `~/.faceless-videos`; downloads the Kokoro voice ~350 MB and Whisper small.en ~0.5 GB). Install what's
missing the free, official way; ask before anything that needs a password. Then `bash SKILL/scripts/selftest.sh`
must print **SELFTEST PASSED** (~5–8 min): open the contact sheets and 4 s clips it names and look at them.

## 1. Pick the style — at most ONE question
If the request doesn't make it obvious, ask once (AskUserQuestion, the three styles with one-line descriptions) and
recommend: survival scenarios, "what would you do", "Part 1" story series, life-in-a-situation → **Lamplit Ink**;
creepy encounters, true crime, unsolved cases, scary stories, "this happened in 1990" → **Red Ghost**; inventions,
origins, "why does X exist", how-it-works, history facts → **Sunlit Explainer**. Then read that style's STYLE.md.

## 2. Intake + plan
Ask what's still unknown in ONE message with defaults filled in: topic or story (or "you pick 3 ideas"), true story
or fiction, length, aspect, narrator voice (`SKILL/scripts/py SKILL/scripts/voice.py --list`), music (keep the style's
score, make an original one with ACE-Step, or their own royalty-free track), end card / handle. "Just go" = defaults.
Then show ONE screen: title, the full narration script, the shot list in one line per shot, the sets/characters you
will build or reuse, music, and the render time. Ask **"Build it?"** and wait.

**Script rules.** Write for the ear: short sentences, one idea each; numbers spelled the way they are said
("nineteen nineteen"); every sentence is a cut point. Original writing only — never copy another creator's script.
True stories and numbers are checked against primary or reliable sources (say which). No gore or injury on screen;
real people only when the story is documented, and treated with respect. Fiction is labelled as a story.

## 3. Build
`bash SKILL/scripts/new_video.sh <style> <short-name>` copies the style's example (engine, sets, characters, shots,
its narration) into `~/faceless-videos/<short-name>/` so it renders straight away. Then follow STYLE.md: write the
script → `voice.py` → `words.py` → rewrite the shots (and sets/characters/cards where the story needs new ones) →
export cues → mix → check → render. Reuse the engine; change the story. Keep the style's rules — they are the look.

## 4. Check before you show anything
Contact sheet of every shot (`node tools/capture.mjs scenes review/all.jpg all 2 0.25`), then the key frames at full
size. Ask of each frame: does it obey the style sheet, does it say what the narration says at that moment, is every
word on screen spelled right and readable on a phone? Captions and cards land on their words, cuts land on sentences.
Audio: voice clear over the music, soft sounds only (no ticks, clicks, hats, glitches, beeps — they hurt on phone
speakers), the levels STYLE.md gives. Fix and re-check; never ship a frame you haven't looked at.

## 5. Deliver
The master MP4 (`renders/<name>.mp4`), a share copy under ~35 MB (`ffmpeg -i master.mp4 -c:v libx264 -crf 20
-preset slow -c:a aac -b:a 160k -movflags +faststart share.mp4`), the best cover frame, and a title + caption +
5–8 hashtags (for a series: "Part 2" teaser line). Open the video for the user. Offer one round of precise changes
("slower on the twist", "different voice") and re-render only what changed.

## Never
Generate images or video with AI (this skill's point is that everything is built in code); spend money; overwrite a
user's project without asking; re-run `mix.py` while a render is muxing (it reads `data/mix.wav` at the end); run
ACE-Step music with less than 10 GB of free disk (`make_music.sh` refuses — a 16 GB machine can restart).
