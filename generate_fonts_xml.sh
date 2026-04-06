#!/bin/bash
styles=("Classic" "ClassicMini" "Modern" "ModernMini")
CHARACTERS=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "!")
DATE_CHARS=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")

echo "<fonts>"
for style in "${styles[@]}"; do
    # DSEG7 Large
    echo "    <font id=\"DSEG7_${style}_Large\">"
    for j in "${!CHARACTERS[@]}"; do
        code=$([ $j -lt 10 ] && echo $((48 + j)) || echo 33)
        echo "        <char code=\"${code}\" filename=\"${style}_D7_Large.png\" />"
    done
    echo "    </font>"

    # DSEG7 Medium
    echo "    <font id=\"DSEG7_${style}_Medium\">"
    for j in "${!CHARACTERS[@]}"; do
        code=$([ $j -lt 10 ] && echo $((48 + j)) || echo 33)
        echo "        <char code=\"${code}\" filename=\"${style}_D7_Medium.png\" />"
    done
    echo "    </font>"

    # DSEG7 Small
    echo "    <font id=\"DSEG7_${style}_Small\">"
    for j in "${!CHARACTERS[@]}"; do
        code=$([ $j -lt 10 ] && echo $((48 + j)) || echo 33)
        echo "        <char code=\"${code}\" filename=\"${style}_D7_Small.png\" />"
    done
    echo "    </font>"

    # DSEG14 Date
    echo "    <font id=\"DSEG14_${style}_Date\">"
    for j in "${!DATE_CHARS[@]}"; do
        code=$([ $j -lt 10 ] && echo $((48 + j)) || echo $((55 + j)))
        echo "        <char code=\"${code}\" filename=\"${style}_D14_Date.png\" />"
    done
    echo "    </font>"
done
echo "</fonts>"
