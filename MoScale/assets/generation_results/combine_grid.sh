#!/bin/bash
# Combine 6 method videos into a 3x2 grid with labels
# Layout:
#   MoScale       | MoMask++       | SALAD
#   StableMoFusion| T2M-GPT        | MDM

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONTSIZE=28
LABEL_HEIGHT=50
PAD=4
BG_COLOR="white"
TEXT_COLOR="black"

for i in 0 1 2 3; do
    echo "=== Processing gen_${i} ==="
    
    INPUT_MOSCALE="gen_${i}_moscale.mkv"
    INPUT_MOMASKPLUS="gen_${i}_momaskplus.mkv"
    INPUT_SALAD="gen_${i}_salad.mkv"
    INPUT_STABLEMOFUSION="gen_${i}_stablemofusion.mkv"
    INPUT_T2MGPT="gen_${i}_t2mgpt.mkv"
    INPUT_MDM="gen_${i}_mdm.mkv"
    OUTPUT="gen_${i}_combined.mp4"

    # Check all inputs exist
    for f in "$INPUT_MOSCALE" "$INPUT_MOMASKPLUS" "$INPUT_SALAD" "$INPUT_STABLEMOFUSION" "$INPUT_T2MGPT" "$INPUT_MDM"; do
        if [ ! -f "$f" ]; then
            echo "  Missing: $f, skipping gen_${i}"
            continue 2
        fi
    done

    ffmpeg -y \
        -i "$INPUT_MOSCALE" \
        -i "$INPUT_MOMASKPLUS" \
        -i "$INPUT_SALAD" \
        -i "$INPUT_STABLEMOFUSION" \
        -i "$INPUT_T2MGPT" \
        -i "$INPUT_MDM" \
        -filter_complex "
            [0:v]scale=640:756:force_original_aspect_ratio=decrease,pad=640:756:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR},pad=640:756+${LABEL_HEIGHT}:0:0:color=${BG_COLOR},drawtext=fontfile=${FONT}:text='MoScale':fontcolor=${TEXT_COLOR}:fontsize=${FONTSIZE}:x=(w-text_w)/2:y=756+((${LABEL_HEIGHT}-text_h)/2)[v0];
            [1:v]scale=640:756:force_original_aspect_ratio=decrease,pad=640:756:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR},pad=640:756+${LABEL_HEIGHT}:0:0:color=${BG_COLOR},drawtext=fontfile=${FONT}:text='MoMask++':fontcolor=${TEXT_COLOR}:fontsize=${FONTSIZE}:x=(w-text_w)/2:y=756+((${LABEL_HEIGHT}-text_h)/2)[v1];
            [2:v]scale=640:756:force_original_aspect_ratio=decrease,pad=640:756:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR},pad=640:756+${LABEL_HEIGHT}:0:0:color=${BG_COLOR},drawtext=fontfile=${FONT}:text='SALAD':fontcolor=${TEXT_COLOR}:fontsize=${FONTSIZE}:x=(w-text_w)/2:y=756+((${LABEL_HEIGHT}-text_h)/2)[v2];
            [3:v]scale=640:756:force_original_aspect_ratio=decrease,pad=640:756:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR},pad=640:756+${LABEL_HEIGHT}:0:0:color=${BG_COLOR},drawtext=fontfile=${FONT}:text='StableMoFusion':fontcolor=${TEXT_COLOR}:fontsize=${FONTSIZE}:x=(w-text_w)/2:y=756+((${LABEL_HEIGHT}-text_h)/2)[v3];
            [4:v]scale=640:756:force_original_aspect_ratio=decrease,pad=640:756:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR},pad=640:756+${LABEL_HEIGHT}:0:0:color=${BG_COLOR},drawtext=fontfile=${FONT}:text='T2M-GPT':fontcolor=${TEXT_COLOR}:fontsize=${FONTSIZE}:x=(w-text_w)/2:y=756+((${LABEL_HEIGHT}-text_h)/2)[v4];
            [5:v]scale=640:756:force_original_aspect_ratio=decrease,pad=640:756:(ow-iw)/2:(oh-ih)/2:color=${BG_COLOR},pad=640:756+${LABEL_HEIGHT}:0:0:color=${BG_COLOR},drawtext=fontfile=${FONT}:text='MDM':fontcolor=${TEXT_COLOR}:fontsize=${FONTSIZE}:x=(w-text_w)/2:y=756+((${LABEL_HEIGHT}-text_h)/2)[v5];
            [v0][v1][v2]hstack=inputs=3[row0];
            [v3][v4][v5]hstack=inputs=3[row1];
            [row0][row1]vstack=inputs=2[out]
        " \
        -map "[out]" \
        -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
        -shortest \
        "$OUTPUT"
    
    echo "  Created: $OUTPUT"
done

echo "Done!"
