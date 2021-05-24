#!/usr/bin/env bash
#
# People still think they can easily trap errors in functions.
# https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
# https://stackoverflow.com/questions/64786/error-handling-in-bash
#
# However the behavior depdends on too many things to be safely understood
# and thus you should not rely on it.
#
# If you still love Bash (as I do) then consider the following simple rules:
#
#   1. Only write small bash "programs"
#   2. Use `set -e` as a VERY rudimentary measure to make Bash scripst fail fast.
#   3. Prefer to use if-then-else or && and || to explicitly handle errors.
#   4. You must use if-then-else or && and || to handle errors in functions!
#

# The following code is shows that you cannot safely and consistently
# trap errors in functions and for loops.

# Some devs advocate to use a smart trap the checks if you are in a func or not.
trace=""
trap '{
    code=$?
    trace="error code=$code at $BASH_COMMAND in $0:$LINENO ($FUNCNAME)"
    echo "DEBUG: $trace"
    if test $FUNCNAME
    then return $code
    else echo "$trace"; exit $code
    fi
}' ERR

set -eE  # This is supposed to do the trick (spoiler: it is a total fail!)

err_inside(){
  test -z "err_inside"
  echo "ERROR: this should never be shown"
}

err_at_end() {
  test -z "err_at_end"
}

err_in_if() {
    if test -z "err_in_if"; then return 0; fi
    echo "INFO: this must be shown (err_in_if)"
}

err_in_for() {
    for i in 1 2 3; do test $i -eq 2; done
    echo "ERROR: loop should not finish, code=$?"
}

err_catched() {
    test -z "err_catched" || echo "catched code=$?"
    echo "INFO: this must be shown (err_catched)"
}

handle_error() {
    # Using another command or function is a common way handling errors in bash.
    # However, using `err_cmd || handle_error` will also break the ERR trap for `err_cmd`
    true
}

must_fail() {
    "$1" || handle_error
    # Trying to atch the error to inspect the trace will also breaksand set -E traps.
    # This hen-egg problem cannot be solved easily (i.e., without a ton of hacks).
    code=$? trapped=$trace trace=''
    if   test "$code" = "0"; then echo "ERROR: command must fail, cmd=$1"
    elif test -z "$trapped"; then echo "ERROR: command must be trapped, cmd=$1"
    else                          echo "OK: command was trapped, cmd=$1"
    fi
}

must_not_fail() {
    "$1" || handle_error
    code=$? trapped=$trace trace=''
    if   test "$code" != "0"; then echo "ERROR: command must not fail, cmd=$1"
    elif test -n "$trapped";  then echo "ERROR: command must not be trapped, cmd=$1"
    else                           echo "OK: command was not trapped, cmd=$1"
    fi
}

must_not_fail err_catched "catched errors must not be trapped"
must_not_fail err_in_if   "if-checked error must not be trapped"
must_fail     err_in_for  "loop errors should be trapped"
must_fail     err_at_end  "last line errors must be trapped"
must_fail     err_inside  "error in script must be trapped"

echo '🛑 All the ERRORS show you that `set -eE` cannot be trusted! 🛑'
