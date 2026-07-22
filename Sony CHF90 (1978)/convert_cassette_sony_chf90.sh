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
                       aevalsrc=exprs='(random(0)-0.5)*0.008|(random(1)-0.5)*0.008':s=44100[static]; \
                       [music][static]amix=inputs=2:duration=first:dropout_transition=0:normalize=0[mixed]; \
                       [mixed]vibrato=f=2.0:d=0.025,vibrato=f=14.0:d=0.007,highpass=f=50,lowpass=f=13500, \
                       equalizer=f=250:width_type=q:width=1.0:g=0.5,equalizer=f=8000:width_type=q:width=0.7:g=-3.5[out]" \
      -map "[out]" \
      -c:a libmp3lame -b:a 192k \
      "$TARGET_DIR/${base_name}.mp3"
done