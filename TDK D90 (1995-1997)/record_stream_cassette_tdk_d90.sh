#!/bin/bash

# Enforce strict error handling
set -e

# Default to primary relay if no argument is provided
STREAM_URL="${1:-http://ice6.somafm.com/dronezone-128-aac}"

echo "Initiating degraded capture pipeline for: $STREAM_URL"
echo "Target destination: $(pwd)"
echo "Press [q] inside this terminal to stop recording gracefully."
echo "------------------------------------------------------------"

ffmpeg -y -loglevel info -stats -i "$STREAM_URL" \
  -filter_complex "aevalsrc=exprs='(random(0)-0.5)*0.006|(random(1)-0.5)*0.006':s=44100[static]; \
  [delayed_music][static]amix=inputs=2:duration=longest:dropout_transition=0:normalize=0[mixed]; \
  [mixed]vibrato=f=1.8:d=0.015,vibrato=f=15.0:d=0.003,highpass=f=40,lowpass=f=14500, \
  equalizer=f=3000:width_type=q:width=0.5:g=1.5,equalizer=f=10000:width_type=q:width=0.7:g=-2[out]" \
  -c:a aac -b:a 192k \
  -f segment \
  -segment_time 2700 \
  -strftime 1 \
  "./dronezone_cassette_%Y-%m-%d_%H-%M-%S.aac"