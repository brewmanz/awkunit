#!/usr/bin/awk -f
@load "awkunit"

# inside a BEGIN block 'above' here, maybe set
# AWKUNIT_TERMINAL_ERR = "\033[1;41m"
# AWKUNIT_TERMINAL_RESET = "\033[0m"

#  # Find test names like T1234....
#  print FONT_YELLOW "GetDumpOfArray(, PROCINFO[\"identifiers\"] ..." FONT_RESET > "/dev/stderr"
#  PROCINFO["sorted_in"] = "@ind_str_asc" # options are @unsorted, @ind_str_asc, @ind_num_asc, @val_type_asc, @val_str_asc, @val_num_asc; also ..._desc
#  _pattern = "\\[T[0-9]{4}[a-zA-Z0-9_]*" # [T1234....
#  delete _arr
#  GetDumpOfArray(_arr, PROCINFO["identifiers"])
#  print FONT_YELLOW "GetDumpOfArray(, PROCINFO[\"identifiers\"] filtered for Tests ..." FONT_RESET > "/dev/stderr"
#  delete _ListOfTests
#  for(_key in _arr){
#    if(_arr[_key] == "user" && _key ~ _pattern){
#      match(_key, _pattern)
#      myMatch = substr( _key, RSTART+1, RLENGTH-1 )
#      if(TPR_DEBUG) { print "[" _key "]=" _arr[_key] " > " RSTART, ", " RLENGTH, ", ", myMatch }
#      print " will run " myMatch
#      _ListOfTests[myMatch] = myMatch
#    }
#  }
#  # Do tests
#  for(_keyTest in _ListOfTests){
#    print FONT_YELLOW _keyTest FONT_RESET > "/dev/stderr"
#    @_keyTest()
#  }

BEGIN{
  _assert_exit = 0
}

function assert(condition, string, _hint)
{
    if (!condition) {
        printf("%sAssertion failed: %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, string, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        ++_assert_exit
        exit 1
    }
}
function assertEquals(value1, value2, _hint)
{
    if (value1 != value2) {
        printf("%sAssertion failed: %s is not equal to %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, value1, value2, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        ++_assert_exit
        exit 1
    }
}
function assertNotEquals(value1, value2, _hint)
{
    if (value1 == value2) {
        printf("%sAssertion failed: %s is equal to %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, value1, value2, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        ++_assert_exit
        exit 1
    }
}
function expectEquals(value1, value2, _hint)
{
    if (value1 != value2) {
        ++_assert_exit
        printf("%sExpectation failure #%d: %s is not equal to %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, _assert_exit, value1, value2, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        #exit 1
    }
}
function expectNotEquals(value1, value2, _hint)
{
    if (value1 == value2) {
        ++_assert_exit
        printf("%sExpectation failure #%d: %s is equal to %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, _assert_exit, value1, value2, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        #exit 1
    }
}
function expectNear(value1, value2, diff, _hint                     , _delta)
{
    _delta = value1 - value2
    if(_delta < 0) { _delta = -_delta }
    if(_delta > diff){
        ++_assert_exit
        printf("%sExpectation failure #%d: %s is not near to %s ± %s; out by %s. Hint:%s.%s\n", \
          AWKUNIT_TERMINAL_ERR, _assert_exit, value1, value2, diff, _delta, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        #exit 1
    }
}
function expectNotNear(value1, value2, diff, _hint                     , _delta)
{
    _delta = value1 - value2
    if(_delta < 0) { _delta = -_delta }
    if(_delta < diff){
        ++_assert_exit
        printf("%sExpectation failure #%d: %s is near to %s ± %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, _assert_exit, value1, value2, diff, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        #exit 1
    }
}

END {
    if (_assert_exit){
        printf("%sawkunit: Unit Test failure: assert/expect failures=%d%s\n", AWKUNIT_TERMINAL_ERR, _assert_exit, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        exit 1
    }
}
