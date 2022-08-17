#!/usr/bin/awk -f
@load "awkunit"

function assert(condition, string, _hint)
{
    if (!condition) {
        printf("Assertion failed: %s. Hint:%s.\n", string, _hint) > "/dev/stderr"
        _assert_exit = 1
        exit 1
    }
}

function assertEquals(value1, value2, _hint)
{
    if (value1 != value2) {
        printf("Assertion failed: %s is not equal to %s. Hint:%s.\n", value1, value2, _hint) > "/dev/stderr"
        _assert_exit = 1
        exit 1
    }
}

function expectEquals(value1, value2, _hint)
{
    if (value1 != value2) {
        printf("Expectation failed: %s is not equal to %s. Hint:%s.\n", value1, value2, _hint) > "/dev/stderr"
        _assert_exit = 1
        #exit 1
    }
}

function expectNear(value1, value2, diff, _hint                     , _delta)
{
    _delta = value1 - value2
    if(_delta < 0) { _delta = -_delta }
    if(_delta > diff){
        printf("Expectation failed: %s is not near to %s ± %s. Hint:%s.\n", value1, value2, diff, _hint) > "/dev/stderr"
        _assert_exit = 1
        #exit 1
    }
}

END {
    if (_assert_exit){
        exit 1
    }
}
