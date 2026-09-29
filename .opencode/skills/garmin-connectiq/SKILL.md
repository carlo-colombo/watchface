---
name: garmin-connectiq
description: Build, sign, simulate, and deploy Garmin ConnectIQ apps and watchfaces written in Monkey C for vivoactive5
---

# Garmin ConnectIQ Workflow

Use this skill when building, running, releasing, or deploying either ConnectIQ project in this repository.

## Project Structure

This repo has two projects under `/home/carlo/projects/watchface/`:

- `9segments-on/` — watchface (type: `watchface`), entry: `_9segmentsOnApp`, target: `vivoactive5`
- `themind/` — watch app (type: `watch-app`), entry: `TheMindApp`, target: `vivoactive5`

Each project has a `monkey.jungle` pointing to `manifest.xml`.

## Toolchain and Signing

- ConnectIQ SDK: `/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`
- Java: Zulu 21 (managed via asdf and `.tool-versions`)
- Developer key: `developer_key` in the repository root; it is gitignored and must never be exposed or committed.

## Build

Run commands from the repository root. Ensure the signing key exists before building. Create output directories only if needed.

### Debug build for simulator

```bash
java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar \
  -o 9segments-on/bin/9segments-on.prg -f 9segments-on/monkey.jungle \
  -y developer_key -d vivoactive5_sim -w
```

### Release build for physical device

Use `-r` and target the physical `vivoactive5` device:

```bash
java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar \
  -o 9segments-on/bin/9segments-on-release.prg -f 9segments-on/monkey.jungle \
  -y developer_key -d vivoactive5 -r -w
```

For `themind`, substitute `themind/bin/themind.prg` or `themind/bin/themind-release.prg` and `themind/monkey.jungle` as appropriate.

## Simulator

Start the simulator in the background so the command does not block:

```bash
/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/connectiq &
```

Run a compiled program on the simulator:

```bash
/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo 9segments-on/bin/9segments-on.prg vivoactive5
```

Stop the simulator when needed:

```bash
pkill -f connectiq
```

Ensure the simulator is running before invoking `monkeydo`. If the app does not launch, check the simulator state, build output, `monkey.jungle`, and `manifest.xml`.

## Deploy to Physical Watch (MTP)

Connect the vivoactive 5 over USB and use one of these methods.

### Via `kioclient` (KDE)

```bash
# Inspect the mounted MTP device name
kioclient ls "mtp:/"

# Upload release builds
kioclient copy 9segments-on/bin/9segments-on-release.prg "mtp:/vívoactive 5/Internal Storage/GARMIN/Apps/9segments-on.prg"
kioclient copy themind/bin/themind-release.prg "mtp:/vívoactive 5/Internal Storage/GARMIN/Apps/themind.prg"
```

### Via `gio` (requires `gvfs-mtp`)

KDE's MTP handler can conflict with `gio`; stop it before mounting:

```bash
killall kiod6
gio mount "mtp://091e_514a_0000d7ee64c5/"
gio copy 9segments-on/bin/9segments-on-release.prg "mtp://091e_514a_0000d7ee64c5/Internal Storage/GARMIN/Apps/9segments-on.prg"
gio copy themind/bin/themind-release.prg "mtp://091e_514a_0000d7ee64c5/Internal Storage/GARMIN/Apps/themind.prg"
gio mount -u "mtp://091e_514a_0000d7ee64c5/"
```

Find the current device URI with `gio mount -l -i` and inspect the `activation_root` information. The example USB ID is `091e:514a`.

### Via `mtp-sendfile` (direct libmtp)

Stop KDE's MTP handler first if it has claimed the device:

```bash
killall kiod6
mtp-sendfile 9segments-on/bin/9segments-on-release.prg "GARMIN/Apps/9segments-on.prg"
```

The device path is case-sensitive and must target `GARMIN/Apps/`.

## After Deployment

- Disconnect the watch from USB.
- For the watchface: long-press the current watch face, then go to Settings → Watch Face → Add New.
- For the app: find it in the app list; restart the watch if it does not appear.

## Troubleshooting

- `libusb_claim_interface() reports device is busy`: KDE's `kiod6` may own the device; stop it before using `gio` or `mtp-sendfile`.
- `gio: Couldn't find matching udev device`: install `gvfs-mtp` (on Arch Linux: `sudo pacman -S gvfs-mtp`).
- Build failures: verify the manifest target device and the `monkey.jungle` manifest path.
- Simulator run failures: start the ConnectIQ simulator before `monkeydo` and confirm the `.prg` was successfully built for the simulator target.
