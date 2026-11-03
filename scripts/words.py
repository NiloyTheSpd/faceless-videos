"""Word timings for the narration with local Whisper (faster-whisper small.en) → data/words.json.

  scripts/py scripts/words.py <project>                      data/narration.wav + the script → data/words.json
  scripts/py scripts/words.py <project> --audio my_voice.m4a  use your own recording (becomes data/narration.wav)

data/words.json = [{"w": "phone", "s": 2.31, "e": 2.6}, …] — what the shots' w()/wt() look up. The words keep the
SCRIPT's spelling (script.json lines or script.txt), with the times Whisper heard; words it heard differently
("1919" vs "nineteen nineteen") share the heard span by length, words it missed share the gap between neighbours.
Also writes data/words.txt (one word per line) to eyeball the timing.
"""
import argparse, json, re, subprocess, sys
from difflib import SequenceMatcher
from pathlib import Path

norm = lambda w: re.sub(r'[^a-z0-9]+', '', w.lower())


def script_words(P):
    if (P / 'script.json').exists():
        text = ' '.join(l['text'] for l in json.loads((P / 'script.json').read_text())['lines'])
    elif (P / 'script.txt').exists():
        text = re.sub(r'^\s*#.*$', '', (P / 'script.txt').read_text(), flags=re.M)
    else:
        return None
    return [w for w in text.split() if norm(w)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('project')
    ap.add_argument('--audio', help='your own narration file (any format) → data/narration.wav')
    ap.add_argument('--no-script', action='store_true', help="use Whisper's own words (unscripted recording)")
    ap.add_argument('--model', default='small.en', help='base.en is faster, medium.en more exact')
    a = ap.parse_args()
    P = Path(a.project); (P / 'data').mkdir(parents=True, exist_ok=True)
    wav = P / 'data/narration.wav'
    if a.audio:
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', a.audio, '-ac', '2', '-ar', '48000', '-c:a', 'pcm_s16le', str(wav)], check=True)
    if not wav.exists():
        sys.exit(f'missing {wav} (make it with voice.py, or pass --audio <file>)')
    dur = float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(wav)], capture_output=True, text=True).stdout.strip())

    from faster_whisper import WhisperModel
    print(f'listening with Whisper {a.model}…', flush=True)
    m = WhisperModel(a.model, device='cpu', compute_type='int8')
    segs, _ = m.transcribe(str(wav), language='en', word_timestamps=True, beam_size=5, vad_filter=False, condition_on_previous_text=False)
    heard = [{'w': w.word.strip(), 's': round(w.start, 3), 'e': round(w.end, 3)} for s in segs for w in (s.words or []) if norm(w.word)]
    if not heard:
        sys.exit('Whisper heard no words — is the narration silent?')

    sw = None if a.no_script else script_words(P)
    if not sw:
        words = heard
    else:
        A, B = [norm(w) for w in sw], [norm(w['w']) for w in heard]
        times = [None] * len(sw)
        ops = SequenceMatcher(None, A, B, autojunk=False).get_opcodes()
        for tag, i1, i2, j1, j2 in ops:
            if tag == 'equal':
                for k in range(i2 - i1): times[i1 + k] = (heard[j1 + k]['s'], heard[j1 + k]['e'])
            elif tag == 'replace':
                t0, t1 = heard[j1]['s'], heard[j2 - 1]['e']
                L = [max(1, len(A[i])) for i in range(i1, i2)]; tot = sum(L); c = 0
                for k, n in enumerate(L):
                    times[i1 + k] = (round(t0 + (t1 - t0) * c / tot, 3), round(t0 + (t1 - t0) * (c + n) / tot, 3)); c += n
        i = 0
        while i < len(sw):
            if times[i] is None:
                j = i
                while j < len(sw) and times[j] is None: j += 1
                t0 = times[i - 1][1] if i > 0 else 0.0
                t1 = times[j][0] if j < len(sw) else dur
                for k in range(j - i):
                    times[i + k] = (round(t0 + (t1 - t0) * k / (j - i), 3), round(t0 + (t1 - t0) * (k + 1) / (j - i), 3))
                i = j
            else:
                i += 1
        words = [{'w': w, 's': s, 'e': e} for w, (s, e) in zip(sw, times)]
        exact = sum(i2 - i1 for tag, i1, i2, *_ in ops if tag == 'equal')
        print(f'{len(sw)} script words, {len(heard)} heard, {exact} matched exactly')

    (P / 'data/words.json').write_text(json.dumps(words, indent=0))
    (P / 'data/words.txt').write_text('\n'.join(f"{w['s']:7.2f} {w['e']:7.2f}  {w['w']}" for w in words) + '\n')
    print(f"{P / 'data/words.json'}  {len(words)} words, narration {dur:.1f}s")


if __name__ == '__main__':
    main()
