# Prints a stacktrace (a la java) to stdout
# If any arguments are given they are shows as the exception message
function assert.stack_trace() {
    echo "Exception: $@"
    let local stack_frame=0
    local line=$(caller "${stack_frame}")
    while test -n "${line}"
    do
        echo "    at: ${line}"
        stack_frame=$((${stack_frame}+1))
        line=$(caller "${stack_frame}")
    done
}
readonly -f assert.stack_trace

# Asserts that a program/function completes with a 0 exit code, else exits
# the current script with a code of 1
# Arguments:
#  1. The message to emit on failure
#  2..* the program (and arguments) to execute
function assert.true() {
    local message="${1}"
    shift
    "$@" || { assert.stack_trace "${message}
Caused by: $@" >&2 ; exit 1 ; }
    return 0
}
readonly -f assert.true

# Asserts that a program/function completes with a non-0 exit code, else exits
# the current script with a code of 1
# Arguments:
#  1. The message to emit on failure
#  2..* the program (and arguments) to execute
function assert.false() {
    local message="${1}"
    shift
    "$@" && { assert.stack_trace "${message}
Caused by: $@" >&2 ; exit 1 ; }
    return 0
}
readonly -f assert.false

# Asserts that two values are equal, else exits the current script with a code
# of 1
# Arguments:
#  1. The message to emit on failure
#  2. First argument (expected)
#  3. Second argument (actual)
function assert.equals() {
    local message="${1}"
    test "${2}" = "${3}" || { assert.stack_trace "${message}
Caused by: Actual value '${3}' does not match expected value '${2}'" >&2 ; exit 1 ; }
    return 0
}
readonly -f assert.equals

# Asserts that two values are not equal, else exits the current script with a
# code of 1
# Arguments:
#  1. The message to emit on failure
#  2. First argument (expected)
#  3. Second argument (actual)
function assert.not_equals() {
    local message="${1}"
    test "${2}" = "${3}" && { assert.stack_trace "${message}
Caused by: Values '${2}' and '${3}' should not match" >&2 ; exit 1 ; }
    return 0
}
readonly -f assert.not_equals
