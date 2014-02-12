#!/bin/sh
HERE=`dirname $0`
WOUNDMAP="$HERE/../WoundMapUS"
cd "$WOUNDMAP"
mogenerator -m WoundMapUS.xcdatamodeld --human-dir Common/Classes/Model/ --machine-dir Common/Classes/Model/machine --template-var arc=true