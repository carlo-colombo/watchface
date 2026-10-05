# Garmin ConnectIQ Projects

This repository contains Garmin ConnectIQ applications written in Monkey C and targeting the vivoactive 5.

## Projects

- `9segments-on/` — watchface; entry class `_9segmentsOnApp`; target `vivoactive5`.
- `themind/` — watch app; entry class `TheMindApp`; target `vivoactive5`.
- Both projects have a `monkey.jungle` pointing to `manifest.xml`.

## 9segments Watchface

The watchface displays a minimalist seven-segment digital clock and activity metrics (steps, heart rate, and temperature), with customizable foreground/background colors and a debug alignment grid. It supports 12/24-hour formats, although the current implementation favors 12-hour display.

Key source files under `9segments-on/source/`:

- `9segmentsApp.mc` — application entry point and lifecycle.
- `9segmentsView.mc` — watchface layout, updates, complications, and high-/low-power rendering.
- `9segmentsBackground.mc` — background drawing.

The watchface renders digits using bundled DSEG font resources. Monkey C classes use PascalCase; variables and functions use camelCase.

The always-on / low-power clock uses a fixed neutral gray (`0x333333`, approximately 3.3% linear luminance) and hollow `DSEG7_ClassicHollow` hour and `DSEG7_Classic_MediumHollow` minute fonts. AOD hue and luminosity are intentionally not configurable; change the color in `9segmentsView.mc` and rebuild if this behavior needs to change. Other foreground/background and font settings remain separate high-power watchface settings.

Resources are under `9segments-on/resources/` (`drawables/`, `fonts/`, `layouts/`, `settings/`, and `strings/`).

## Toolchain and Credentials

- ConnectIQ SDK: `/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`
- Java: Zulu 21, managed with asdf and `.tool-versions`.
- The Connect IQ simulator needs `libjxl.so.0.11`. Manjaro's `pacman -S libjxl` provides 0.12, so use the available 0.11 compatibility libraries via `LD_LIBRARY_PATH=/tmp/connectiq-libjxl-0.11/usr/lib`.
- Signing key: `developer_key` in the repository root. It is ignored by Git; never expose or commit it.

## Run 9segments Watchface in the Connect IQ Simulator

Run commands from the repository root. Detach both the GUI and app launcher so the terminal/tool returns immediately. Bound the app launcher with `timeout` so it cannot wait indefinitely; the simulator GUI remains open for inspection.

1. Build for the simulator:
   `java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar -o 9segments-on/bin/9segments-on.prg -f 9segments-on/monkey.jungle -y developer_key -d vivoactive5_sim -w`
2. Set the library path and start the simulator in the background if it is not already running:
   ```bash
   export LD_LIBRARY_PATH="/tmp/connectiq-libjxl-0.11/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
   if ! pgrep -x simulator >/dev/null; then
       nohup setsid env LD_LIBRARY_PATH="$LD_LIBRARY_PATH" /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/connectiq > /tmp/connectiq-simulator.log 2>&1 < /dev/null &
       sleep 2
   fi
   ```
3. Launch the app helper detached with a 30-second maximum runtime; this command returns immediately:
   ```bash
   nohup setsid env LD_LIBRARY_PATH="$LD_LIBRARY_PATH" timeout --signal=TERM --kill-after=5s 30s \
       /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo \
       9segments-on/bin/9segments-on.prg vivoactive5 \
       > /tmp/connectiq-monkeydo.log 2>&1 < /dev/null &
   echo "App launcher PID: $!"
   ```
4. Check simulator logs without following them indefinitely: `tail -n 30 /tmp/connectiq-simulator.log /tmp/connectiq-monkeydo.log`
5. Stop the simulator when finished: `pkill -x simulator`

If launch fails, inspect those logs and verify `LD_LIBRARY_PATH` points to the directory containing `libjxl.so.0.11` and `libjxl_threads.so.0.11`.

## Deploy 9segments Watchface to vivoactive 5

1. Connect the watch by USB and confirm it appears over MTP:
   `kioclient ls "mtp:/"`
2. Build the signed release from the repository root:
   `java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar -o 9segments-on/bin/9segments-on-release.prg -f 9segments-on/monkey.jungle -y developer_key -d vivoactive5 -r -w`
3. Copy the release to the watch (replace the existing file if prompted):
   `kioclient copy 9segments-on/bin/9segments-on-release.prg "mtp:/vívoactive 5/Internal Storage/GARMIN/Apps/9segments-on.prg"`
4. Verify the file is present:
   `kioclient ls "mtp:/vívoactive 5/Internal Storage/GARMIN/Apps/"`
5. Disconnect the watch from USB to load the updated app.

If the MTP device is missing, reconnect the watch and confirm the mounted device name with `kioclient ls "mtp:/"` before copying. For simulator operation and additional deployment methods, load the `garmin-connectiq` skill.
