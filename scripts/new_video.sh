#!/bin/bash
# Start a new video from a style's working example.
#   bash new_video.sh <style> <short-name> [--dir <parent>]      → ~/faceless-videos/<short-name>/
# styles: lamplit-ink (story cartoon, 9:16) · red-ghost (horror / true-crime reconstruction, 9:16 + 16:9)
#         sunlit-explainer (3D history / how-it-works explainer, 16:9)
# The copy is the full example (engine + sets + shots + its narration), so it renders straight away; then you
# rewrite script → voice → words → shots/sets → cues → mix → render (see styles/<style>/STYLE.md).
set -eu
SKILL="$(cd "$(dirname "$0")/.." && pwd)"
STYLE="${1:?usage: new_video.sh <lamplit-ink|red-ghost|sunlit-explainer> <short-name> [--dir <parent>]}"; NAME="${2:?short name missing}"
PARENT="$HOME/faceless-videos"; [ "${3:-}" = "--dir" ] && PARENT="${4:?}"
case "$STYLE" in
  lamplit*|ink|story|cartoon|beanie) STYLE=lamplit-ink ;;
  red*|ghost|horror|crime) STYLE=red-ghost ;;
  sunlit*|explainer|3d|history) STYLE=sunlit-explainer ;;
  *) echo "unknown style: $STYLE (lamplit-ink | red-ghost | sunlit-explainer)" >&2; exit 2 ;;
esac
SRC="$SKILL/styles/$STYLE/example"; DST="$PARENT/$NAME"
[ -e "$DST" ] && { echo "$DST already exists — pick another name or delete it first" >&2; exit 2; }
mkdir -p "$PARENT"; cp -R "$SRC" "$DST"
# the skill stores the example's audio compressed; the tools want WAV
[ -f "$DST/data/narration.flac" ] && ffmpeg -v error -y -i "$DST/data/narration.flac" -c:a pcm_s16le "$DST/data/narration.wav" && rm "$DST/data/narration.flac"
mkdir -p "$DST/renders" "$DST/review"
if [ "$STYLE" = sunlit-explainer ]; then
  echo "sculpting + skinning the cast (data/chars/*.bin, ~15 s per character)…"
  (cd "$DST" && node tools/build_chars.mjs) > "$DST/data/build.log" 2>&1 || { echo "build_chars failed: see $DST/data/build.log" >&2; exit 1; }
fi
echo "$DST"
echo "style: $STYLE — read $SKILL/styles/$STYLE/STYLE.md before changing anything"
