#!/bin/bash

# Test the single inverter
lib_template_file=custom/template.lib
lib_templateo_file=custom/templateo.lib
BASE_DIR=custom/OpenRule1um_StdCell
TIMESTEP=10e-12
MODEL_SP=ngspice/main.lib
CELL_LIST_FILE=${BASE_DIR}/cell_list/OpenRule1um_StdCell.txt

# NOTE: This technology doesn't have corners... so that is why we only
# do variations in voltage and temperatore
CORNER_NAMES=("TT_5p0v_27c" "TT_3p8v_125c" "TT_6p2v_m40c")
VOLTAGES=("5.0" "3.8" "6.2")
TEMPS=("27.0" "125.0" "-40.0")
CORNERS=("typical" "worst" "best")

for i in {0..2}; do
    CORNER_NAME=${CORNER_NAMES[$i]}
    VOLTAGE=${VOLTAGES[$i]}
    TEMP=${TEMPS[$i]}
    CORNER=${CORNERS[$i]}
    echo "Performing corner: $CORNER_NAME"

    CHAR_FOLDER="chars/${CORNER_NAME}"

    mkdir -p ${CHAR_FOLDER}
    sed "s;__CORNER_NAME__;${CORNER_NAME};; s;__VOLTAGE__;${VOLTAGE};; s;__TEMP__;${TEMP};;" ${lib_template_file} > ${lib_templateo_file}

    # Read file_list.txt line by line and execute the command
    while IFS= read -r CELL || [[ -n "$CELL" ]]; do
        # Skip empty lines
        [[ -z "$CELL" ]] && continue

        # Skip already characterized libs
        LIB_OUT=${CHAR_FOLDER}/${CELL}.lib
        [[ -f "${LIB_OUT}" ]] && continue

        # The only filler cell needs to be skipped
        [[ $CELL == "fill" ]] && continue

        echo "Processing: $CELL"

        > char/${CELL}.log

        lctime --liberty ${lib_templateo_file} --include ${MODEL_SP} \
            --output-loads "0.05, 0.1, 0.2, 0.4, 0.8, 1.6" \
            --slew-times "0.1, 0.2, 0.4, 0.8, 1.6, 3.2" \
            --spice ${BASE_DIR}/spice/OpenRule1um_StdCell.sp \
            --cell ${CELL} \
            --related-pin-transition "0.1" \
            --time-step ${TIMESTEP} \
            --calc-mode ${CORNER} \
            --output ${LIB_OUT} |& tee ${CHAR_FOLDER}/${CELL}.log
    done < "$CELL_LIST_FILE"

    python3 ../common/create_lib_library.py ${CHAR_FOLDER} OpenRule1um_StdCell_${CORNER_NAME}

done
