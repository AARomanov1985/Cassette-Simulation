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
  -f lavfi -i "aevalsrc=exprs='(random(0)-0.5)*0.02|(random(1)-0.5)*0.02':s=44100" \
  -filter_complex "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=0[mixed]; \
  [mixed]vibrato=f=2.2:d=0.08,vibrato=f=16.0:d=0.02,highpass=f=75,lowpass=f=9000, \
  equalizer=f=400:width_type=q:width=1.0:g=4,equalizer=f=6000:width_type=q:width=0.8:g=-6" \
  -c:a aac -b:a 192k \
  -f segment \
  -segment_time 1800 \
  -strftime 1 \
  "./dronezone_cassette_%Y-%m-%d_%H-%M-%S.aac"