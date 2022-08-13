#!/usr/bin/awk -f
@include "awkunit" # note that its embedded BEGIN, if any, will run before BEGIN below
#@include "~/git/awkunit/examples/sum.awk"
@include "sum" # note that its embedded BEGIN, if any, will run before BEGIN below

function testSum_Orig() {
    assertEquals(0, sum("0"))
    assertEquals(3, sum("1 2"))
    assertEquals(-2, sum("3 -5"))
    assertEquals(17, sum("2 5 10"))
}

function testSum_WithHint() {
    data = "0" ; assertEquals(0, sum(data), data )
    data = "1 2" ; assertEquals(3, sum(data), data )
    data = "3 -5" ; assertEquals(-2, sum(data), data )
    data = "2 5 10" ; assertEquals(17, sum(data), data )
}

function testIO_TwoFiles() {
    awkunit::assertIO("sum.awk", "sum.in", "sum.ok")
}

function testIO_FromOneFile() {
    awkunit::assertIO("sum.awk", "tmpData.in", "tmpData.ok")
}

BEGIN {
  print "Test Starting ..." > "/dev/stderr"
  print "(Input file being processed)" > "/dev/stderr"
  _FS_Save = FS
  FS = "~=>"
  while(getline == 1){
    print "($1='" $1 "', $2='" $2 "'" > "/dev/stderr"
    if(NF != 2){
      print "!!Expected just the one FS of '" FS "' but line=<" $0 ">" > "/dev/stderr"
    }
  }
  FS = _FS_Save
  print "testSum_Orig ..." > "/dev/stderr"
    testSum_Orig()
  print "testSum_WithHint ..." > "/dev/stderr"
    testSum_WithHint()
  print "testIO_TwoFiles ..." > "/dev/stderr"
    testIO_TwoFiles()
  print "... Test Finished" > "/dev/stderr"
    exit 0
}
