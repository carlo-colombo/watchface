#!/bin/bash
mkdir -p 9segments/resources/fonts
# ... (same setup as before)
CHARACTERS=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "!")
# Use a dot for space to represent it in the script, then rename.
DATE_CHARS=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "." )

# ... (same loop structure)
    # 4. DSEG14 Date (Small 20pt, Full Alpha)
    for j in "${!DATE_CHARS[@]}"; do
        char="${DATE_CHARS[$j]}"
        [ "$char" == "." ] && char=" "
        magick -background none -fill white -font "${dseg14_path}" -pointsize 20 -gravity center label:"$char" -extent 17x20 "${tmp_dir}/d14_date_${j}.png"
    done
    magick "${tmp_dir}/d14_date_"{0..36}.png +append "9segments/resources/fonts/${style}_D14_Date.png"
# ...
