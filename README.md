# video-processor

A simple CLI tool for processing videos.

It normalizes audio and generates SRT subtitles automatically using FFmpeg and Faster-Whisper.

## Features

- Normalize audio loudness.
- Keep the original video without re-encoding.
- Convert audio to AAC for better compatibility.
- Generate SRT subtitles automatically.
- Process a video with a single command.

## Requirements

- Bash
- FFmpeg
- Python 3
- Faster-Whisper

Install Faster-Whisper with:

```bash
pip install faster-whisper
```

Install FFmpeg using your system's package manager.

## Usage

Make the script executable:

```bash
chmod +x video-processor.sh
```

Run it with a video file:

```bash
./video-processor.sh video.mp4
```

The script will generate:

```text
video_processed.mp4
video.srt
```

The processed video contains the normalized audio. The subtitles are saved separately as an SRT file.

## Audio Processing

Audio is normalized using FFmpeg's `loudnorm` filter:

```text
I=-14:TP=-1.5:LRA=11
```

The video stream is copied without re-encoding:

```text
-c:v copy
```

This avoids unnecessary video encoding and preserves the original video quality.

Audio is encoded as AAC at 192 kbps:

```text
-c:a aac -b:a 192k
```

## Subtitle Generation

Subtitles are generated using Faster-Whisper with the `small` model.

The output uses the standard SRT format and can be imported into most video editors and media players.

## Example

```bash
./video-processor.sh recording.mp4
```

Output:

```text
Processing: recording.mp4
Normalizing audio...
Audio normalization complete.
Generating subtitles...
Subtitles saved to: recording.srt

Done.
Video: recording_processed.mp4
Subtitles: recording.srt
```

## How It Works

1. FFmpeg reads the input video.
2. The original video stream is copied.
3. The audio is normalized and encoded as AAC.
4. Faster-Whisper transcribes the video.
5. The transcription is saved as an SRT file.

The goal is to keep the workflow simple: one input video, one processed video, and one subtitle file.

## Burn Subtitles Into the Video

If you want the subtitles to be permanently visible in the video, you can burn the SRT file into the processed video using FFmpeg:

```bash
ffmpeg -i video_processed.mp4 -vf "subtitles=video.srt" -c:a copy video_subtitled.mp4
