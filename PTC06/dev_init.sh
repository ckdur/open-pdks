#!/bin/bash

# This script is intended for the developing of the OpenRule1um PDK
# The idea is to clone the up-to-date PDK here, so the other byproducts
# can be generated or developed from scratch.

# For making the actual PDK using open-pdks, just use regular Makefile.in

# Support from mineda (Klayout files)
git clone https://github.com/mineda-support/OpenRule1um.git
# Standard cells and etc
git clone https://github.com/ishi-kai/OpenRule1umPDK_setupEDA.git
# For reference
git clone https://github.com/MakeLSI/OpenRule1um.git OpenRule1um_MakeLSI

# Copy just enough stuff to the custom folder
# Remember: We do not want to duplicate references
# So these are not supposed to get into the repo

mkdir -p ngspice
mkdir -p custom/OpenRule1um_StdCell/gds
mkdir -p custom/OpenRule1um_StdCell/spice
mkdir -p custom/OpenRule1um_StdCell/cdl
mkdir -p custom/OpenRule1um_StdCell/cell_list

# Organizing the GDS and the available CDL and spice files
cp OpenRule1um/Basic/libraries/OpenRule1um_StdCell.gds custom/OpenRule1um_StdCell/gds
> "custom/OpenRule1um_StdCell/cdl/OpenRule1um_StdCell.cdl"
find OpenRule1um/tech/tech/models/ishi-kai-lib/stdcells_lvs/ -type f -maxdepth 1 | while read -r file; do
    cat "$file" >> "custom/OpenRule1um_StdCell/cdl/OpenRule1um_StdCell.cdl"
    echo "" >> "custom/OpenRule1um_StdCell/cdl/OpenRule1um_StdCell.cdl"
done
> "custom/OpenRule1um_StdCell/spice/OpenRule1um_StdCell.sp"
> "custom/OpenRule1um_StdCell/cell_list/OpenRule1um_StdCell.txt"
find OpenRule1um/tech/tech/models/ishi-kai-lib/stdcells_sim/ -type f -maxdepth 1 | while read -r file; do
    cat "$file" >> "custom/OpenRule1um_StdCell/spice/OpenRule1um_StdCell.sp"
    echo "" >> "custom/OpenRule1um_StdCell/spice/OpenRule1um_StdCell.sp"
    filename=$(basename "$file")
    echo "${filename%.*}" >> "custom/OpenRule1um_StdCell/cell_list/OpenRule1um_StdCell.txt"
done

# Copying the models in an organized manner
cp OpenRule1um/tech/tech/models/BSIM3V3N.mod ngspice/BSIM3V3N.mod
cp OpenRule1um/tech/tech/models/BSIM3V3P.mod ngspice/BSIM3V3P.mod
cp OpenRule1um/tech/tech/models/ishi-kai-lib/mos.lib ngspice/mos.lib
cp OpenRule1um/tech/tech/models/ishi-kai-lib/diode.lib ngspice/diode.lib
cp OpenRule1um/tech/tech/models/ishi-kai-lib/passive.lib ngspice/passive.lib
