#!/usr/bin/env bash
set -e

INPUT="${1:?Usage: $0 video.mp4}"

DIR="$(dirname "$INPUT")"
NAME="$(basename "${INPUT%.*}")"

OUTPUT="$DIR/${NAME}_processed.mp4"
SUBTITLES="$DIR/${NAME}.srt"

echo "Processing: $INPUT"
echo "Normalizing audio..."

ffmpeg -y -i "$INPUT" \
  -map 0:v:0 \
  -map 0:a:0 \
  -c:v copy \
  -c:a aac \
  -b:a 192k \
  -af "loudnorm=I=-14:TP=-1.5:LRA=11" \
  "$OUTPUT"

echo "Audio normalization complete."
echo "Generating subtitles..."

python3 - "$INPUT" "$SUBTITLES" <<'PY'
import sys
from faster_whisper import WhisperModel

video = sys.argv[1]
output = sys.argv[2]

model = WhisperModel(
    "small",
    device="auto",
    compute_type="auto",
)

segments, _ = model.transcribe(video, vad_filter=True)


def format_time(seconds):
    milliseconds = int(seconds * 1000)

    hours = milliseconds // 3_600_000
    milliseconds %= 3_600_000

    minutes = milliseconds // 60_000
    milliseconds %= 60_000

    seconds = milliseconds // 1_000
    milliseconds %= 1_000

    return f"{hours:02}:{minutes:02}:{seconds:02},{milliseconds:03}"


with open(output, "w", encoding="utf-8") as subtitles:
    for index, segment in enumerate(segments, start=1):
        subtitles.write(f"{index}\n")
        subtitles.write(
            f"{format_time(segment.start)} --> "
            f"{format_time(segment.end)}\n"
        )
        subtitles.write(f"{segment.text.strip()}\n\n")

print(f"Subtitles saved to: {output}")
PY

echo
echo "Done."
echo "Video: $OUTPUT"
echo "Subtitles: $SUBTITLES"
