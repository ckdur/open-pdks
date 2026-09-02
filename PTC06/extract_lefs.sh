#!/bin/bash

# probably redundant
THIS_PWD=$(pwd)

GDS2LEF=${THIS_PWD}/custom/scripts/gds2lef.sh
CREATELEF=${THIS_PWD}/../common/create_lef_library.py

BASE_DIR=${THIS_PWD}/custom/OpenRule1um_StdCell
RCFILE=${THIS_PWD}/magic/PTC06.magicrc
GDS=${BASE_DIR}/gds/OpenRule1um_StdCell.gds
FINAL_LEF=${BASE_DIR}/lef/OpenRule1um_StdCell.lef

mkdir -p ${THIS_PWD}/lefs
(cd ${THIS_PWD}/lefs && bash ${GDS2LEF} ${GDS} ${RCFILE})
python3 ${CREATELEF} ${THIS_PWD}/lefs OpenRule1um_StdCell