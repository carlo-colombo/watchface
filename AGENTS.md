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

The always-on / low-power clock digits use a fixed neutral gray (`0x555555`, approximately 9% linear luminance). AOD hue and luminosity are intentionally not configurable; change the color in `9segmentsView.mc` and rebuild if this behavior needs to change. Other foreground/background and font settings remain separate high-power watchface settings.

Resources are under `9segments-on/resources/` (`drawables/`, `fonts/`, `layouts/`, `settings/`, and `strings/`).

## Toolchain and Credentials

- ConnectIQ SDK: `/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`
- Java: Zulu 21, managed with asdf and `.tool-versions`.
- Signing key: `developer_key` in the repository root. It is ignored by Git; never expose or commit it.

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
