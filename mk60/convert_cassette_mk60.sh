#!/bin/bash
set -e
shopt -s nullglob nocaseglob

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
                       aevalsrc=exprs='(random(0)-0.5)*0.02|(random(1)-0.5)*0.02':s=44100[static]; \
                       [music][static]amix=inputs=2:duration=first:dropout_transition=0[mixed]; \
                       [mixed]vibrato=f=2.2:d=0.08,vibrato=f=16.0:d=0.02,highpass=f=75,lowpass=f=9000, \
                       equalizer=f=400:width_type=q:width=1.0:g=4,equalizer=f=6000:width_type=q:width=0.8:g=-6[out]" \
      -map "[out]" \
      -c:a libmp3lame -b:a 192k \
      "$TARGET_DIR/${base_name}.mp3"
done