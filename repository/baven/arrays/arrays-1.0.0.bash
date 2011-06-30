# Tests whether a given value exists in an array
# Arguments:
#   1. Array name (*not* the array value)
#   2. The value to test for (say /usr/bin)
# Exit codes
#   0   If the value is contained in the array
#   !0  If the value is not in the array
function arrays.contains() {
    assert.true "arrays.contains <array name> <value>" test "$#" -eq 2
    local array_name="${1}"
    local value="${2}"
    eval "for val in \"\${${array_name}[@]}\"; do
        test \"\${val}\" = \"${value}\" && return 0
    done"
    return 1
}
readonly -f arrays.contains

# Populates an array variable with the values of a passed in list starting at
# index 0
# Arguments:
#   1. Array name (*not* the array value)
#   2. The list separator, default is ':'
# Emitted value to stdout:
#   a list containing the ordered array values
function arrays.to_list() {
    assert.true "arrays.to_list <array name> [separator]" test "$#" -eq 1 -o "$#" -eq 2
    local array_name="${1}"
    local separator="${2:-:}"
    local new_list=""
    eval "for val in \"\${${array_name}[@]}\"; do
        if test -z \"\${new_list}\"; then
            new_list=\"\${val}\"
        else
            new_list=\"\${new_list}${separator}\${val}\"
        fi
    done"
    echo "${new_list}"
}
readonly -f arrays.to_list

# Runs a given function/command for each value of an array, testing for success. As soon
# as a success is found (zero exit code) this function will return 0
# Arguments:
#   1.   Array name (*not* the array value)
#   2..* The program/function for each array value, plus any additional arguments
#        to be passed for each call.  These additional arguments are passed
#        *before* the array value
# Exit codes
#   0 if any execution exited with code 0
#   1 if no executions exited with code 0
function arrays.any() {
    assert.true "arrays.any <array name> <function/program and arguments...>" test "$#" -ge 2
    local array_name="${1}"
    shift 1
    eval "for val in \"\${${array_name}[@]}\"; do
        \"\$@\" \"\${val}\" && return 0
    done"
    return 1
}
readonly -f arrays.any

# Runs a given function/command for each value of an array, testing for success. As soon
# as a failure is found (non-zero exit code) this function will return 1; 0 will be returned
# if the function/command succeeds for all values in the named array
# Arguments:
#   1.   Array name (*not* the array value)
#   2..* The program/function for each array value, plus any additional arguments
#        to be passed for each call.  These additional arguments are passed
#        *before* the array value
# Exit codes
#   0 if all executions exited with code 0
#   1 if any execution exited with a non-zero exit code
function arrays.all() {
    assert.true "arrays.all <array name> <function/program and arguments...>" test "$#" -ge 2
    local array_name="${1}"
    shift 1
    eval "for val in \"\${${array_name}[@]}\"; do
        \"\$@\" \"\${val}\" || return 1
    done"
    return 0
}
readonly -f arrays.all

$(bvn.load_plugin baven assert 1.0.0)
