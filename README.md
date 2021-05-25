# scripts
Collection of scripts used across programming languages, projects, and systems

## Bash50
[Bash50](bash/.bash50rc) provides (less than) 50 lines of code for your Bash
scripts to make them a bit safer and provide better error and debug messages.

### Installation
```bash
curl -o .bash50rc https://raw.githubusercontent.com/ubunatic/scripts/main/bash/.bash50rc
```

### Usage
Bash50 provides the functions `dt`, `log`, `err`, `debug`, `fail`, and `var`,
which can be used as follows.
```bash
source .bash50rc

echo "It is time! `dt`"
# It is time! 2021-05-24 23:09:41

log "Hello!"
err "This should not have happened!"
# 2021-05-24 23:10:21: [INFO] Hello!
# 2021-05-24 23:10:21: [ERROR] This should not have happened!

DEBUG=1
var a = b
var $a = 1
debug "a=$a b=$b"
# 2021-05-24 23:12:09: [DEBUG] setting a = b
# 2021-05-24 23:12:09: [DEBUG] setting b = 1
# 2021-05-24 23:12:09: [INFO] a=b b=1

true || fail "did not expect true to fail"
fail "must fail and exit the script"
# 2021-05-24 23:14:22: [ERROR] must fail and exit the script, code=1 at `false` in bash:19
# exit
```
Also see the [tests](bash/test.sh) for more usage examples.