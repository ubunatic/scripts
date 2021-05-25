#!/usr/bin/env bash
source "`dirname $0`/.bash50rc"

log_ok()  { log "[Test:OK] $*"; }
log_err() { err "[Test:FAILED] $*"; }

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
    var "v=123"    ; test "$v" = "123"   || fail "expected value '123', got '$v'"
    var v=x=y=z    ; test "$v" = "x=y=z" || fail "expected value to preseve equal signs, got $v"
    var v = 1=2=3  ; test "$v" = "1=2=3" || fail "expected value to be stripped, got $v"
    var v=         ; test -z "$v"        || fail "expected empty value, got $v"
    var v =        ; test -z "$v"        || fail "expected empty value, got $v"
    var v=1; var v ; test "$v" = "1"     || fail "expected non-empty value, got $v"
}

test_log() {
            log   "TEST" 2>&1 | grep "INFO.*TEST"  || fail "bad info log"
            err   "TEST" 2>&1 | grep "ERROR.*TEST" || fail "bad error log"
    DEBUG=1 debug "TEST" 2>&1 | grep "DEBUG.*TEST" || fail "bad debug log"
            debug "TEST" 2>&1 | grep ''            && fail "expected empty debug log" || true

}

test_debug() {
    DEBUG=1  var a=1 2>&1 | grep "setting" || fail "var must use debug log"
    DEBUG='' var a=1 2>&1 | grep ""        && fail "var must use debug log" || true
}

if test $# -eq 0
then var tests = "var errfunc log debug"
else var tests = "$*"
fi

for t in $tests; do "test_$t" && log_ok "$t" || log_err "test failed $t"; done
