# 9segments Watchface

A Garmin ConnectIQ watchface featuring a minimalist 7-segment digital clock and key activity metrics.

## Project Overview

- **Type:** Garmin ConnectIQ Watchface
- **Target Device:** vivoactive5
- **Language:** Monkey C
- **Key Features:**
    - Large 7-segment digital display for hours.
    - Minutes displayed within the second hour digit.
    - Complications: Steps, Heart Rate, and Temperature (all using scaled 7-segment digits).
    - Customizable colors (Background, Foreground).
    - Debug grid for alignment.
    - Support for 12/24h formats (though implementation currently favors 12h).

## Architecture

- `9segmentsApp.mc`: Application entry point and lifecycle management.
- `9segmentsView.mc`: Main watchface view, handling layout, updates, and complication drawing.
- `SevenSegmentDigit.mc`: Custom class for rendering digits using 7-segment polygons. Supports scaling and custom colors.
- `9segmentsBackground.mc`: Placeholder for background drawing (currently simple layout-based).

## Building and Running

### Prerequisites
- Garmin ConnectIQ SDK (installed at `~/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/`)
- Developer Key (`developer_key`) in the project root.

### Build Command
To compile the watchface for the `vivoactive5` simulator:
```bash
java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar -o 9segments/bin/9segments.prg -f 9segments/monkey.jungle -y developer_key -d vivoactive5_sim -w
```

### Run Command
1.  **Start the Simulator:**
    ```bash
    /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/connectiq
    ```
2.  **Run the Watchface:**
    ```bash
    /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo 9segments/bin/9segments.prg vivoactive5
    ```

## Development Conventions

- **Source Code:** All Monkey C files are in `9segments/source/`.
- **Resources:**
    - `9segments/resources/drawables/`: Icons and graphics.
    - `9segments/resources/layouts/`: UI layout definitions.
    - `9segments/resources/settings/`: Properties and settings definitions for user customization.
    - `9segments/resources/strings/`: Localization strings.
- **Naming:** Classes and variables follow standard Monkey C conventions (PascalCase for classes, camelCase for variables/functions).
- **Custom Drawing:** Use the `SevenSegmentDigit` class for any digit rendering to maintain visual consistency.
