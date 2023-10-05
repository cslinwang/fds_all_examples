#!/bin/bash
dir=`pwd`
target=${dir##*/}
CFLAGS="-fprofile-arcs -ftest-coverage -g"
LDFLAGS="-lgcov"

echo Building $target
make -j4 VPATH="../../Source" -f ../makefile CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" $target
