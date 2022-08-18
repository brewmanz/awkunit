#!/usr/bin/awk -f
@load "awkunit"

function assert(condition, string, _hint)
{
    if (!condition) {
        printf("%sAssertion failed: %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, string, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        _assert_exit = 1
        exit 1
    }
}

function assertEquals(value1, value2, _hint)
{
    if (value1 != value2) {
        printf("%sAssertion failed: %s is not equal to %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, value1, value2, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        _assert_exit = 1
        exit 1
    }
}

function expectEquals(value1, value2, _hint)
{
    if (value1 != value2) {
        printf("%sExpectation failed: %s is not equal to %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, value1, value2, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        _assert_exit = 1
        #exit 1
    }
}

function expectNear(value1, value2, diff, _hint                     , _delta)
{
    _delta = value1 - value2
    if(_delta < 0) { _delta = -_delta }
    if(_delta > diff){
        printf("%sExpectation failed: %s is not near to %s ± %s. Hint:%s.%s\n", AWKUNIT_TERMINAL_ERR, value1, value2, diff, _hint, AWKUNIT_TERMINAL_RESET) > "/dev/stderr"
        _assert_exit = 1
        #exit 1
    }
}

END {
    if (_assert_exit){
        exit 1
    }
}
