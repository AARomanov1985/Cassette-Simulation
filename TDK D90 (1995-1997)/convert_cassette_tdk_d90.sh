#!/bin/bash
set -e
shopt -s nullglob nocaseglob
aac)
./convert_cassette_*.sh

# Record a live web stream into segment files
./record_stream_cassette_*.sh [STREAM_URL]
TARGET_DIR="./out"
mkdir -p "$TARGET_DIR"

# Gather targets directly
files=(*.mp3 *.ogg *.m4a *.aac)
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No source assets found."
    exit 1
fi

for file in "${files[@]}"; do
    filename=$(basename "$file")
    base_name="${filename%.*}"
    
    ffmpeg -y -i "$file" \
      -filter_complex "aresample=44100,aformat=sample_fmts=fltp:channel_layouts=stereo[music]; \
                       aevalsrc=exprs='(random(0)-0.5)*0.006|(random(1)-0.5)*0.006':s=44100[static]; \
                       [music][static]amix=inputs=2:duration=first:dropout_transition=0:normalize=0[mixed]; \
                       [mixed]vibrato=f=1.8:d=0.015,vibrato=f=15.0:d=0.003,highpass=f=40,lowpass=f=14500, \
                       equalizer=f=3000:width_type=q:width=0.5:g=1.5,equalizer=f=10000:width_type=q:width=0.7:g=-2[out]" \
      -map "[out]" \
      -c:a libmp3lame -b:a 192k \
      "$TARGET_DIR/${base_name}.mp3"
done
