#!/usr/bin/tcl

# Exclusive for the standard cells of OpenRule1um


crashbackups stop
#gds flatglob *__example_*
#gds flatten true
gds read $env(GDS)
set base [file rootname $env(GDS)]

# Definition of common ports for the OpenRule1um_StdCell
set ports {VDD   VSS    X      Y} ; # The rest are inputs by default
set dirs  {inout inout  output output}
set uses  {power ground signal signal}
set valid_cells "inv1 inv4 inv8 \
buf1 buf2 buf4 buf8 \
cinv \
na21 na31 na41 nr21 nr31 \
an21 an31 an41 or21 or31 \
exnr exor \
na212 na222 nr212 nr222 \
FILL \
dff1 dff1_r dff1m2 dff1m2_r \
rff1 rff1_r rff1m2 rff1m2_r \
sff1 sff1_r sff1m2 sff1m2_r"
set LEFsite "core"
set LEFsymmetry "X Y R90"

# Get all the cells
set cells [cellname list allcells]
foreach cell $cells {
    set find [lsearch $valid_cells $cell]
    if {$find < 0} {
        continue ; # Skip
    }
    load $cell
    puts "Processing $cell"
    set properties [property]
    foreach property [property] {
        if {[lindex $property 0] == "FIXED_BBOX"} {
            puts "%OL_METRIC_I llx [lindex $property 1]"
            puts "%OL_METRIC_I lly [lindex $property 2]"
            puts "%OL_METRIC_I urx [lindex $property 3]"
            puts "%OL_METRIC_I ury [lindex $property 4]"
        }
    }
    select top cell
    set minp [port first]
    set maxp [port last]
    puts "  processing $minp-$maxp ports.."
    for {set i $minp} {$i <= $maxp} {incr i} {
        set name [port $i name]
        if {$name == ""} {
            continue ; # Skip undetected ones
        }
        set find [lsearch $ports $name]
        puts "    Port: ${name}"
        if {$find >= 0} {
            set class [lindex $dirs $find]
            set use [lindex $uses $find]
            puts "      Setting port $name to $class, $use"
            port $i class $class
            port $i use $use
            if {$use == "power" || $use == "ground"} {
                port $i shape abutment
            }
        } else {
            # Inputs by default
            port $i class input
            port $i use signal
        }
    }
    property LEFclass CORE
    property LEFsite $LEFsite
    property LEFsymmetry $LEFsymmetry
    lef write $cell.lef
} 

quit

