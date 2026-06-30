---
name: garmin-connectiq
description: Build, sign, simulate, and deploy Garmin ConnectIQ apps and watchfaces (Monkey C) to vivoactive5 via MTP
---

# Garmin ConnectIQ Workflow

## Project Structure

This repo has two projects under `/home/carlo/projects/watchface/`:
- `9segments/` — watchface (type: `watchface`), entry: `_9segmentsApp`, target: `vivoactive5`
- `themind/` — watch-app (type: `watch-app`), entry: `TheMindApp`, target: `vivoactive5`

Each has a `monkey.jungle` (single line: `project.manifest = manifest.xml`) and `manifest.xml`.

SDK: `/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`
Java: `zulu-21.36.19` (managed via asdf/.tool-versions)
Dev key: `developer_key` in project root (gitignored)

## Builds

### Debug (simulator)
```bash
java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar \
  -o 9segments/bin/9segments.prg -f 9segments/monkey.jungle \
  -y developer_key -d vivoactive5_sim -w
```

### Release (device)
Add `-r` flag:
```bash
java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar \
  -o 9segments/bin/9segments-release.prg -f 9segments/monkey.jungle \
  -y developer_key -d vivoactive5 -r -w
```

For `themind`, replace paths/names accordingly.

## Simulator

```bash
# Start (background)
/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/connectiq &

# Run a PRG
/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo 9segments/bin/9segments.prg vivoactive5

# Stop
pkill -f connectiq
```

## Deploy to Physical Watch (MTP)

The vivoactive 5 connects as an MTP device (USB ID `091e:514a`).

### Via kioclient (KDE — no setup needed)
```bash
# Find device name
kioclient ls "mtp:/"
# Upload
kioclient copy 9segments/bin/9segments-release.prg "mtp:/vívoactive 5/Internal Storage/GARMIN/Apps/9segments.prg"
kioclient copy themind/bin/themind-release.prg "mtp:/vívoactive 5/Internal Storage/GARMIN/Apps/themind.prg"
```

### Via gio (requires gvfs-mtp package)
```bash
# Kill KDE MTP handler first (conflicts with gio)
killall kiod6

# Mount
gio mount "mtp://091e_514a_0000d7ee64c5/"

# Copy
gio copy 9segments/bin/9segments-release.prg "mtp://091e_514a_0000d7ee64c5/Internal Storage/GARMIN/Apps/9segments.prg"
gio copy themind/bin/themind-release.prg "mtp://091e_514a_0000d7ee64c5/Internal Storage/GARMIN/Apps/themind.prg"

# Unmount
gio mount -u "mtp://091e_514a_0000d7ee64c5/"

# Find device URI
gio mount -l -i  # look for activation_root
```

### Via mtp-sendfile (direct libmtp)
```bash
# Kill KDE MTP handler first
killall kiod6
# Send file to GARMIN/Apps/
mtp-sendfile 9segments/bin/9segments-release.prg "GARMIN/Apps/9segments.prg"
```

## After Deployment
- Disconnect USB
- For watchface: long-press watch face → Settings → Watch Face → Add New
- For app: appears in app list; restart watch if missing
- The GARMIN/Apps/ folder path is case-sensitive on the device

## Troubleshooting
- `libusb_claim_interface() reports device is busy` → KDE kiod6 holds the device, kill it first
- `gio: Couldn't find matching udev device` → install gvfs-mtp (`sudo pacman -S gvfs-mtp`)
- Build fails → check `manifest.xml` target device and monkey.jungle path
