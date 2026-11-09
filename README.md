# Moonlight Artemis for Nintendo Switch

**Built for the lowest latency possible on the Nintendo Switch.**

Moonlight Artemis is a game streaming client for the Nintendo Switch (homebrew NSP), tuned for the lowest possible input-to-screen latency.
It streams games and your desktop from a PC running [Sunshine](https://github.com/LizardByte/Sunshine)
or [Apollo](https://github.com/ClassicOldSong/Apollo).

It is based on **[XITRIX/Moonlight-Switch](https://github.com/XITRIX/Moonlight-Switch)** 1.5.0 and adds
features from **[Artemis](https://github.com/ClassicOldSong/moonlight-android)** (ClassicOldSong's Moonlight fork).
It installs as its own app, "Moonlight Artemis" (app ID `0100A7E3A7E00000`), so it can sit next to stock Moonlight.

## Features vs stock Moonlight-Switch

Moonlight Artemis is made for the lowest latency possible. It ships with stock-smooth defaults so it works well on every setup, and its Artemis latency options cut delay further:

**For the lowest latency:** set *Frame pacing* to **Lowest latency**, turn **Low latency audio** on, and keep V-Sync on. If you see any stutter on your network, step back to *Balanced*.

**Latency (Artemis)** (Settings tab)
- **Frame pacing**: *Smoothest (stock, default)* (3-frame queue) / *Balanced* (2-frame queue) /
  *Lowest latency* (no jitter reserve, frames shown in order, backlog trimmed only if it persists).
- **V-Sync while streaming**: on by default. Turning it off uses swap interval 0 with a frame cap.
- **Low latency audio**: off by default. When on, it uses 10 ms audio buffers, caps audio lag at about 40 ms, and decodes on the receive thread.

Recommended order to try them. Change one at a time and go back if you see stutter:
1. Frame pacing = **Balanced**
2. Frame pacing = **Lowest latency**
3. **Low latency audio** = on
4. **V-Sync** off (the riskiest one, may tear or stutter)

**Apollo host (Artemis)**
- **Use virtual display**: asks Apollo to create a virtual display that matches the stream.
- **Host display scale** (50–300%).
- **Server commands**: the in-game overlay's Connection tab lists the commands an Apollo host offers and runs them.
- These are only sent to the host when you turn them on.

**Switch limits**
- Resolutions up to **1080p** (900p added). Frame rates up to **60 fps** (45 and 50 fps added). Bitrate up to **100 Mbps**.
  Saved values above these limits are clamped when the app starts.
- Android-only options were removed. Screenshots (Capture button) work. Video recording is off,
  because turning it on in the NACP crashed the system "am" module at launch.

## Install
1. You need a Switch running Atmosphère **with sigpatches** (the NSP is homebrew-signed).
2. Download `MoonlightArtemis-<version>.nsp` from [Releases](../../releases) and install it with **DBI**, **Tinfoil** or **Goldleaf**.
3. Launch **Moonlight Artemis** from the Home menu.
4. **Re-pair your PC.** This app has its own pairing identity (`sdmc:/switch/Artemis-Switch/`):
   Add host, then enter the PIN in Sunshine's or Apollo's web UI.

To update, install the new NSP over the old one. Your settings and pairing are kept.

## Build from source
Requirements: [devkitPro](https://devkitpro.org) with `switch-dev`, deko3d, switch-ffmpeg, switch-curl, switch-mbedtls,
switch-jansson, switch-libopus, switch-sdl2 and switch-glm. You also need CMake, Ninja and pkg-config.
```sh
git clone --recursive https://github.com/rac08241988/Moonlight-Artemis-Switch.git
cd Moonlight-Artemis-Switch
scripts/apply-artemis-patches.sh          # applies patches/ to the borealis + moonlight-common-c submodules
cmake -B build/switch -G Ninja -DPLATFORM_SWITCH=ON -DUSE_DEKO3D=ON -DCMAKE_BUILD_TYPE=Release
ninja -C build/switch Moonlight.nro       # .nro for the Homebrew Launcher
# Optional NSP. Needs hacBrewPack and YOUR OWN prod.keys (never shared here):
KEYS=~/.switch/prod.keys HACBREWPACK=/path/to/hacbrewpack scripts/pack_nsp.sh
```
Note: if devkitPro's `portlibs/switch/include/enet` headers clash with moonlight-common-c's bundled enet, rename that folder.

## Changelog
- **1.0.5**: Fixed the periodic stutter. The default video and audio path now works exactly like stock: triple buffering,
  stock 3-frame queue ("Smoothest"), stock audio. Balanced, Lowest latency, Low latency audio and the Apollo extras
  are opt-in. Settings from older versions are reset to these defaults once.
- **1.0.4**: Fixed the crash at launch (Atmosphère fatal 2128-0007 in "am"). The cause was VideoCapture=Enable in the NACP.
  Video recording is off now. Screenshots still work.
- **1.0.3**: Moved to a standard app ID (`0100A7E3A7E00000`) and matched the packaging of a known-good NSP.
- **1.0.2**: Removed the game-play recording calls at startup in the NSP build.
- **1.0.1**: Capped at 1080p / 60 fps / 100 Mbps for the Switch and clamped saved settings.
- **1.0.0**: First build. Added the Latency (Artemis) options, the Apollo host options (virtual display, scale, server commands),
  900p and 45/50 fps, and the app name "Moonlight Artemis".

## Tested On
- Nintendo Switch, Atmosphère 1.11.2, firmware 22.5.0
- Streaming from a PC with a Ryzen 7 5800X3D and RTX 3070 Ti 8 GB, Windows (AtlasOS)
- Tested by the user: 1.0.5 runs smoothly.

## Credits
- [XITRIX/Moonlight-Switch](https://github.com/XITRIX/Moonlight-Switch) (base app) and XITRIX's
  [borealis](https://github.com/XITRIX/borealis) fork
- [moonlight-common-c](https://github.com/moonlight-stream/moonlight-common-c) (Moonlight Game Streaming Project)
- [Artemis](https://github.com/ClassicOldSong/moonlight-android) and [Apollo](https://github.com/ClassicOldSong/Apollo) by ClassicOldSong
- devkitPro / libnx, FFmpeg, and the other libraries in `extern/`

## License
GPL-3.0. See [LICENSE](LICENSE). This is an unofficial fork and is not affiliated with Nintendo, NVIDIA, XITRIX or ClassicOldSong.
