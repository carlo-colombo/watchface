---
name: garmin-emulator
description: Build Garmin ConnectIQ watchfaces and manage the simulator (start, stop, run). Use when working on Garmin watchface projects to automate the build-run cycle.
---

# Garmin Emulator Skill

This skill provides workflows for building Garmin ConnectIQ watchfaces and interacting with the Garmin simulator.

## Workflow

### 1. Build the Watchface
Use the ConnectIQ compiler (`monkeybrains.jar`) to build the project.

```bash
java -Xms1g -Dfile.encoding=UTF-8 -jar /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar -o 9segments/bin/9segments.prg -f 9segments/monkey.jungle -y developer_key -d vivoactive5_sim -w
```

### 2. Manage the Simulator
Start or stop the Garmin simulator.

- **Start Simulator**: Always run in the background.
  ```bash
  /home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/connectiq
  ```
  *Note: When calling this via `run_shell_command`, set `is_background: true`.*

- **Stop Simulator**: Use `pkill` to terminate the simulator process.
  ```bash
  pkill -f connectiq
  ```

### 3. Run the Watchface
Deploy and run the compiled `.prg` file on the simulator.

```bash
/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeydo 9segments/bin/9segments.prg vivoactive5
```

## Tips
- Always ensure the simulator is running before attempting to run the watchface with `monkeydo`.
- Use `is_background: true` for the `connectiq` command to avoid blocking the agent.
- If the build fails, check the `monkey.jungle` and `manifest.xml` files for configuration errors.
