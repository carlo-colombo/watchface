#!/bin/bash
# Path to ConnectIQ SDK bin
SDK_BIN="/home/carlo/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin"

# 1. Compile the app
echo "Compiling The Mind app..."
mkdir -p themind/bin
java -Xms1g -Dfile.encoding=UTF-8 -jar "$SDK_BIN/monkeybrains.jar" \
     -o themind/bin/themind.prg \
     -f themind/monkey.jungle \
     -y /home/carlo/projects/watchface/developer_key \
     -d vivoactive5_sim \
     -w

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi
echo "Compilation successful!"

# 2. Check if simulator is running, start it if not
if ! pgrep -f "simulator" > /dev/null; then
    echo "Starting Garmin ConnectIQ Simulator..."
    "$SDK_BIN/connectiq" &
    sleep 3
fi

# 3. Run the app
echo "Running The Mind app in simulator..."
"$SDK_BIN/monkeydo" themind/bin/themind.prg vivoactive5
