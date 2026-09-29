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

Resources are under `9segments-on/resources/` (`drawables/`, `fonts/`, `layouts/`, `settings/`, and `strings/`).

## Toolchain and Credentials

- ConnectIQ SDK: `/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`
- Java: Zulu 21, managed with asdf and `.tool-versions`.
- Signing key: `developer_key` in the repository root. It is ignored by Git; never expose or commit it.

For exact debug/release build commands, simulator operation, and physical-device deployment, load the `garmin-connectiq` skill.
