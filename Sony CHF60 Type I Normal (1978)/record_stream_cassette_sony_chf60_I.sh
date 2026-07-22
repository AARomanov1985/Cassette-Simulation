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
  -filter_complex "aevalsrc=exprs='(random(0)-0.5)*0.008|(random(1)-0.5)*0.008':s=44100[static]; \
  [0:a][static]amix=inputs=2:duration=first:dropout_transition=0:normalize=0[mixed]; \
  [mixed]vibrato=f=2.0:d=0.02,vibrato=f=14.0:d=0.005,highpass=f=45,lowpass=f=13500, \
  equalizer=f=250:width_type=q:width=1.0:g=1.5,equalizer=f=8000:width_type=q:width=0.7:g=-3" \
  -c:a aac -b:a 192k \
  -f segment \
  -segment_time 1800 \
  -strftime 1 \
  "./dronezone_cassette_%Y-%m-%d_%H-%M-%S.aac"