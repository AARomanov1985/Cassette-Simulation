# Cassette Simulation

![Cassette Tapes Collection](assets/cassettes.jpeg)

This project simulates cassette tape audio profiles using ffmpeg.

It applies tape noise, wow and flutter pitch modulation, bandwidth limits, and equalizer adjustments.

## Prerequisites

- bash
- ffmpeg (compiled with libmp3lame)

## Repository Structure

- `BASF LH Extra C90`: German ferric tape. Moderate hiss and mild flutter.
- `Maxell UD C90`: Higher-grade ferric tape. Lower hiss, wider frequency range.
- `Sony CHF60 Type I Normal (1978)`: Vintage 60-minute normal tape. Warm mid-range.
- `Sony CHF90 (1978)`: Vintage 90-minute normal tape. Slightly higher tape speed drift.
- `TDK D90 (1995-1997)`: Late-era Type I tape. Clean sound, subtle analog character.
- `mk60`: Soviet MK-60 tape. High tape hiss, heavy wow and flutter, aggressive frequency cut.

## How to Use

Navigate to any cassette folder and run the scripts:

```bash
# Convert local audio files (mp3, ogg, m4a, aac)
./convert_cassette_*.sh

# Record a live web stream into segment files
./record_stream_cassette_*.sh [STREAM_URL]
```

Processed output files will be saved in the `./out` folder.

## License

MIT.
