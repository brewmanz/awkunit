#!/usr/bin/awk -f
@include "awkunit"
#@include "~/git/awkunit/examples/sum.awk"
@include "sum"

function testSum() {
    assertEquals(0, sum("0"))
    assertEquals(3, sum("1 2"))
    assertEquals(-2, sum("3 -5"))
    assertEquals(17, sum("2 5 10"))
}

function testIO() {
    awkunit::assertIO("sum.awk", "sum.in", "sum.ok")
}

BEGIN {
  print "Test Starting ..." > "/dev/stderr"
    testSum()
    testIO()
  print "... Test Finished" > "/dev/stderr"
    exit 0
}
