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
  #print "(Input file being processed)" > "/dev/stderr"
  _FS_Save = FS
  FS = "~=>"
  _nr = 0
  while(getline == 1){
    ++_nr
    #print "($1='" $1 "', $2='" $2 "'" > "/dev/stderr"
    if(NF != 2){
      print "!!Expected just the one FS of '" FS "' but line=<" $0 ">" > "/dev/stderr"
      exit 1
    }
    if(_nr == 1){ # create files 1st time round
      print $1 > "tmpData.in"
      print $2 > "tmpData.ok"
    } else {
      print $1 >> "tmpData.in"
      print $2 >> "tmpData.ok"
    }
  }
  close("tmpData.ok")
  close("tmpData.in")
  FS = _FS_Save
  print "testSum_Orig ..." > "/dev/stderr"
    testSum_Orig()
  print "testSum_WithHint ..." > "/dev/stderr"
    testSum_WithHint()
  print "testIO_TwoFiles ..." > "/dev/stderr"
    testIO_TwoFiles()
  print "testIO_FromOneFile ..." > "/dev/stderr"
    testIO_FromOneFile()
  print "... Test Finished" > "/dev/stderr"
    exit 0
}
