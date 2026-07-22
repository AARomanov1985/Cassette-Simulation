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
                       aevalsrc=exprs='(random(0)-0.5)*0.009|(random(1)-0.5)*0.009':s=44100[static]; \
                       [music][static]amix=inputs=2:duration=shortest:dropout_transition=0:normalize=0[mixed]; \
                       [mixed]vibrato=f=2.3:d=0.022,vibrato=f=16.5:d=0.006,highpass=f=50,lowpass=f=13000, \
                       equalizer=f=500:width_type=q:width=0.8:g=-1.2,equalizer=f=6000:width_type=q:width=0.7:g=-4[out]" \
      -map "[out]" \
      -c:a libmp3lame -b:a 192k \
      "$TARGET_DIR/${base_name}.mp3"
done