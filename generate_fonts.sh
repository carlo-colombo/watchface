#!/bin/bash

# This script generates PNG and FNT files for use as custom fonts in Garmin ConnectIQ.
# It uses ImageMagick (magick command) to render TTF fonts into sprite sheets.

set -e

# Output directory
OUT_DIR="9segments/resources/fonts"
mkdir -p "$OUT_DIR"

# Style names and corresponding directories/files
STYLES=("Classic" "ClassicMini" "Modern" "ModernMini")
D7_DIRS=("DSEG7-Classic" "DSEG7-Classic-MINI" "DSEG7-Modern" "DSEG7-Modern-MINI")
D7_FILES=("DSEG7Classic-Regular.ttf" "DSEG7ClassicMini-Regular.ttf" "DSEG7Modern-Regular.ttf" "DSEG7ModernMini-Regular.ttf")
D14_DIRS=("DSEG14-Classic" "DSEG14-Classic-MINI" "DSEG14-Modern" "DSEG14-Modern-MINI")
D14_FILES=("DSEG14Classic-Regular.ttf" "DSEG14ClassicMini-Regular.ttf" "DSEG14Modern-Regular.ttf" "DSEG14ModernMini-Regular.ttf")

# Characters for DSEG7 (Numbers 0-9 and '!')
D7_CHARS=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "!")

# Characters for DSEG14 (Numbers 0-9, Uppercase A-Z, and Space)
D14_CHARS=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" " ")

# Function to generate a BMFont .fnt file for a sprite sheet
# Usage: generate_fnt <name> <char_width> <char_height> <png_filename> <char_array_name>
generate_fnt() {
    local name=$1
    local width=$2
    local height=$3
    local png_file=$4
    shift 4
    local chars=("$@")
    local count=${#chars[@]}
    local output="${OUT_DIR}/${name}.fnt"
    
    echo "info face=\"${name}\" size=${height} bold=0 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0" > "$output"
    echo "common lineHeight=${height} base=${height} scaleW=$((width * count)) scaleH=${height} pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0" >> "$output"
    echo "page id=0 file=\"${png_file}\"" >> "$output"
    echo "chars count=${count}" >> "$output"
    
    for i in "${!chars[@]}"; do
        local char="${chars[$i]}"
        local char_id
        
        # Determine Unicode ID
        if [ "$char" == "!" ]; then
            char_id=33
        elif [ "$char" == " " ]; then
            char_id=32
        else
            # Use printf to get ASCII value for single character
            char_id=$(printf '%d' "'$char")
        fi
        
        echo "char id=${char_id}   x=$((width * i))     y=0     width=${width}    height=${height}    xoffset=0     yoffset=0     xadvance=${width}    page=0  chnl=15" >> "$output"
    done
}

# Main Loop over styles
for i in "${!STYLES[@]}"; do
    STYLE="${STYLES[$i]}"
    D7_PATH="9segments/fonts/${D7_DIRS[$i]}/${D7_FILES[$i]}"
    D14_PATH="9segments/fonts/${D14_DIRS[$i]}/${D14_FILES[$i]}"
    
    TMP_DIR=$(mktemp -d)
    echo "Generating fonts for style: ${STYLE}..."

    # 1. DSEG7 Large (Hours)
    # Original size: 181x221 -> 241x281 (Requested +60px)
    L_WIDTH=241
    L_HEIGHT=281
    L_POINT=280
    for j in "${!D7_CHARS[@]}"; do
        magick -background none -fill white -font "${D7_PATH}" -pointsize ${L_POINT} -gravity center label:"${D7_CHARS[$j]}" -extent ${L_WIDTH}x${L_HEIGHT} "${TMP_DIR}/d7_large_${j}.png"
    done
    magick "${TMP_DIR}/d7_large_"{0..10}.png +append "${OUT_DIR}/${STYLE}.png"
    generate_fnt "${STYLE}" ${L_WIDTH} ${L_HEIGHT} "${STYLE}.png" "${D7_CHARS[@]}"

    # 2. DSEG7 Medium (Minutes)
    # Reduced width by 10px: 72x81 -> 62x70 (Proportional)
    M_WIDTH=62
    M_HEIGHT=70
    M_POINT=69
    for j in "${!D7_CHARS[@]}"; do
        magick -background none -fill white -font "${D7_PATH}" -pointsize ${M_POINT} -gravity center label:"${D7_CHARS[$j]}" -extent ${M_WIDTH}x${M_HEIGHT} "${TMP_DIR}/d7_med_${j}.png"
    done
    magick "${TMP_DIR}/d7_med_"{0..10}.png +append "${OUT_DIR}/${STYLE}_Medium.png"
    generate_fnt "${STYLE}_Medium" ${M_WIDTH} ${M_HEIGHT} "${STYLE}_Medium.png" "${D7_CHARS[@]}"

    # 3. DSEG7 Small (Complications)
    S_WIDTH=17
    S_HEIGHT=20
    S_POINT=20
    for j in "${!D7_CHARS[@]}"; do
        magick -background none -fill white -font "${D7_PATH}" -pointsize ${S_POINT} -gravity center label:"${D7_CHARS[$j]}" -extent ${S_WIDTH}x${S_HEIGHT} "${TMP_DIR}/d7_small_${j}.png"
    done
    magick "${TMP_DIR}/d7_small_"{0..10}.png +append "${OUT_DIR}/${STYLE}_Small.png"
    generate_fnt "${STYLE}_Small" ${S_WIDTH} ${S_HEIGHT} "${STYLE}_Small.png" "${D7_CHARS[@]}"

    # 4. DSEG14 Date (Alphanumeric)
    D_WIDTH=17
    D_HEIGHT=20
    D_POINT=20
    for j in "${!D14_CHARS[@]}"; do
        char="${D14_CHARS[$j]}"
        if [ "$char" == " " ]; then
            magick -size ${D_WIDTH}x${D_HEIGHT} xc:none "${TMP_DIR}/d14_date_${j}.png"
        else
            magick -background none -fill white -font "${D14_PATH}" -pointsize ${D_POINT} -gravity center label:"${char}" -extent ${D_WIDTH}x${D_HEIGHT} "${TMP_DIR}/d14_date_${j}.png"
        fi
    done
    magick "${TMP_DIR}/d14_date_"{0..36}.png +append "${OUT_DIR}/${STYLE}_D14_Date.png"
    generate_fnt "${STYLE}_D14_Date" ${D_WIDTH} ${D_HEIGHT} "${STYLE}_D14_Date.png" "${D14_CHARS[@]}"

    rm -rf "${TMP_DIR}"
done

echo "Font generation complete!"
