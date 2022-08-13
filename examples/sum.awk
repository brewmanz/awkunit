#!/usr/bin/awk -f

BEGIN {
    FS = "[^0-9+-]+"
    #print "sum.awk BEGIN" > "/dev/stderr"
}

function sum(input) {
    split(input, m, FS)
    ret = 0
    for (i in m)
        ret += m[i]
    return ret
}

{
    #print "sum.awk process '" $0 "'" > "/dev/stderr"
    print sum($0)
}
