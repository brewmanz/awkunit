#!/usr/bin/awk -f
@include "awkunit"
@include "asort"

function testIO() {
    awkunit::assertIO("asort.awk", "/dev/stdin", "asort.ok")
}

BEGIN {
    testIO()
    exit 0
}
