#!/usr/bin/env bash
source "`dirname $0`/.bash50rc"

log_ok()  { log "[Test:OK] $*"; }
log_err() { log "[Test:FAILED] $*"; }

test_mustfail() {
    # example of a failing test (try running `./bake.sh mustfail` to see the output)
    test -z "abc" || fail "must fail"
}

errfunc_ok()  { test -z "abc"; true; }  # last statement is true
errfunc_err() { test -z "abc";       }  # last statement is false

test_errfunc() {
    if ! errfunc_ok;  then fail "errfunc_ok must not fail"; fi
    if   errfunc_err; then fail "errfunc_err must fail";    fi
}

test_var() {
    var "my_var=123"
    test "$my_var" = "123" || fail 'expected value "123"'
}

test_vareq() {
    var "my_var=x=y=z"
    test "$my_var" = "x=y=z" || fail 'expected value to preseve equal signs'
}

if test $# -eq 0
then tests="var vareq errfunc"
else tests="$*"
fi

for t in $tests; do "test_$t" && log_ok "$t" || log_err "test failed $t"; done
