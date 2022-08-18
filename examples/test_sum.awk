#!/usr/bin/awk -f
@include "awkunit" # note that its embedded BEGIN or END, if any, will run before BEGIN or END below
#@include "~/git/awkunit/examples/sum.awk"
@include "sum" # note that its embedded BEGIN or END, if any, will run before BEGIN or END below

BEGIN{
  AWKUNIT_TERMINAL_ERR = "\033[1;41m" # white on red
  AWKUNIT_TERMINAL_RESET = "\033[0m" # reset
}

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

function testSum_expectEqualsWithHints() {
    data = "1 2 3" ; expectEquals(666, sum(data), data " # Fail is expected!")
    data = "1 2 3" ; expectEquals(999, sum(data), data " # Fail is expected!")
    data = "1 2 3" ; expectEquals(333, sum(data), data " # Fail is expected!")
}

function testSum_expectNearWithHints() {
    data = "1 2 3" ; expectNear(6, sum(data), 6, data )
    data = "1 2 3" ; expectNear(5.5, sum(data), 0.49, data " # Fail is expected!")
    data = "1 2 3" ; expectNear(5.5, sum(data), 0.51, data )
    data = "1 2 3" ; expectNear(6.5, sum(data), 0.49, data " # Fail is expected!")
    data = "1 2 3" ; expectNear(6.5, sum(data), 0.51, data )
}

function testIO_TwoFiles() {
    awkunit::assertIO("sum.awk", "sum.in", "sum.ok")
}

function testIO_FromOneFile() {
    awkunit::assertIO("sum.awk", "tmpData.in", "tmpData.ok")
}

function testIO_processIoToArray() {
  delete arr
  awkunit::processIoToArray("sum.awk", "tmpData.in", arr)
  expectEquals(6, length(arr), "length(arr)")
  expectEquals("3", arr[2], "arr[2]")
  expectEquals("465", arr[6], "arr[6]")
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
      print "!!Expected exactly one FS of '" FS "' but line=<" $0 ">" > "/dev/stderr"
      exit 1
    }
    if(_nr == 1){ # create files 1st time round
      print $1 > "tmpData.in"
      print $2 > "tmpData.ok"
    } else { # append after 1st
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
  print "testSum_expectEqualsWithHints ..." > "/dev/stderr"
    testSum_expectEqualsWithHints()
  print "testSum_expectNearWithHints ..." > "/dev/stderr"
    testSum_expectNearWithHints()
  print "testIO_TwoFiles ..." > "/dev/stderr"
    testIO_TwoFiles()
  print "testIO_FromOneFile ..." > "/dev/stderr"
    testIO_FromOneFile()
  print "testIO_processIoToArray ..." > "/dev/stderr"
    testIO_processIoToArray()


  print "... Test Finished" > "/dev/stderr"
    exit 0
}
