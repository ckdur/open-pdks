#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Error: Expected 2 arguments, received $#." >&2
    echo "Usage: $0 <GDS> <RCFILE>" >&2
    exit 1
fi

set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
GDS=$1 magic -dnull -noconsole -rcfile $2 $SCRIPT_DIR/gds2lef.magic.tcl
