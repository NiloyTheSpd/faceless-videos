#!/bin/bash
# Proves the whole pipeline on this computer: local voice + Whisper word timings, then each style's example
# (cues → mix → a contact sheet of every shot → a 4 s clip with sound). ~5–8 minutes. Prints SELFTEST PASSED.
#   bash selftest.sh [style ...]
set -u
SKILL="$(cd "$(dirname "$0")/.." && pwd)"; PY="$SKILL/scripts/py"
T="$HOME/faceless-videos/_selftest"; rm -rf "$T"; mkdir -p "$T"; LOG="$T/selftest.log"; : > "$LOG"
fail=0; note() { printf '%-18s %s\n' "$1" "$2"; }
STYLES="${*:-lamplit-ink red-ghost sunlit-explainer}"

# 1 · voice + words on a two-line script
V="$T/voice-check"; mkdir -p "$V"
printf '{"narrator": {"voice": "am_michael", "speed": 1.0}, "lines": [{"text": "The lights went out at nine.", "gap": 0.3}, {"text": "Nobody came up the stairs.", "gap": 0.5}]}\n' > "$V/script.json"
if "$PY" "$SKILL/scripts/voice.py" "$V" >> "$LOG" 2>&1 && "$PY" "$SKILL/scripts/words.py" "$V" >> "$LOG" 2>&1 \
   && "$PY" -c "import json,sys; w=json.load(open(sys.argv[1])); assert len(w)==11 and w[-1]['e']>w[0]['s'], w" "$V/data/words.json" >> "$LOG" 2>&1; then
  note voice+words "ok ($V/data/words.txt)"
else note voice+words "FAILED (see $LOG)"; fail=1; fi

# 2 · each style: new project from the example → cues → mix → sheet → 4 s clip with sound
clip() { case "$1" in lamplit-ink) echo "21 25" ;; red-ghost) echo "14 18" ;; sunlit-explainer) echo "22.5 26.5" ;; esac; }
for s in $STYLES; do
  P="$T/$s"
  if ! bash "$SKILL/scripts/new_video.sh" "$s" "$s" --dir "$T" >> "$LOG" 2>&1; then note "$s" "FAILED to create (see $LOG)"; fail=1; continue; fi
  (
    cd "$P" || exit 1
    node tools/capture.mjs cues data/cues.json || exit 1
    DUR=$(node tools/capture.mjs eval 'OP.duration()' | head -1)
    "$PY" tools/mix.py . "$DUR" || exit 1
    node tools/capture.mjs scenes review/sheet.jpg all 2 0.25 | tee review/sheet.txt || exit 1
    ! grep -q "SCENE ERRORS" review/sheet.txt || exit 1
    set -- $(clip "$s"); node tools/capture.mjs video renders/selftest.mp4 "$1" "$2" 4 --audio || exit 1
  ) >> "$LOG" 2>&1
  M="$P/renders/selftest.mp4"
  st() { ffprobe -v error -select_streams "$1:0" -show_entries stream=codec_type -of default=nw=1:nk=1 "$M" 2>/dev/null; }
  if [ -f "$M" ] && [ "$(st v)" = video ] && [ "$(st a)" = audio ]; then
    Y=$(ffmpeg -v error -i "$M" -vf "signalstats,metadata=print:key=lavfi.signalstats.YAVG:file=-" -f null - 2>/dev/null | awk -F= '/YAVG/ {s+=$2; n++} END {printf "%d", n ? s/n : 0}')
    A=$(ffmpeg -v info -i "$M" -af volumedetect -vn -f null - 2>&1 | awk '/mean_volume/ {printf "%d", $5}')
    if [ "${Y:-0}" -gt 8 ] && [ "${A:--99}" -gt -45 ]; then note "$s" "ok (sheet: $P/review/sheet.jpg · clip: $M)"; else note "$s" "FAILED: clip looks black (Y=$Y) or silent ($A dB)"; fail=1; fi
  else note "$s" "FAILED (see $LOG)"; fail=1; fi
done
[ $fail = 0 ] && echo "SELFTEST PASSED" || { echo "SELFTEST FAILED — full log: $LOG"; exit 1; }
