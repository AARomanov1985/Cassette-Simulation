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
                       aevalsrc=exprs='(random(0)-0.5)*0.005|(random(1)-0.5)*0.005':s=44100[static]; \
                       [music][static]amix=inputs=2:duration=shortest:dropout_transition=0:normalize=0[mixed]; \
                       [mixed]vibrato=f=2.1:d=0.018,vibrato=f=13.5:d=0.004,highpass=f=35,lowpass=f=15000, \
                       equalizer=f=150:width_type=q:width=1.0:g=2.5,equalizer=f=7000:width_type=q:width=0.8:g=-2.5[out]" \
      -map "[out]" \
      -c:a libmp3lame -b:a 192k \
      "$TARGET_DIR/${base_name}.mp3"
done