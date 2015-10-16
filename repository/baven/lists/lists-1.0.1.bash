# Tests whether a given value exists in a list
# Arguments:
#   1. List value (for example $PATH)
#   2. The value to test for (say /usr/bin)
#   3. The list separator, default is ':'
# Exit codes
#   0   If the value is contained in the list
#   !0  If the value is not in the list
function lists.contains() {
    assert.true "lists.contains <list> <value> [separator]" test "$#" -eq 2 -o "$#" -eq 3
    local list="${1}"
    local value="${2}"
    local separator="${3:-:}"
    for plausible_separator_also_egrep_special in '.' '^' '$' '|' '*' '+' '?';
    do
        test "${separator}" = "${plausible_separator_also_egrep_special}" && separator="\\${separator}"
    done
    echo "${list}" | egrep -q "(^|${separator})${value}(${separator}|$)"
}
readonly -f lists.contains

# Appends an argument to a list, but only if the list does not already
# contain the value.  If you don't care about duplicate values, then a simple
# assignment is probably a better choice than a function call.
# Arguments:
#   1. List value
#   2. The value to append
#   3. The list separator, default is ':'
# Emitted value to stdout:
#   the new list value
function lists.append() {
    assert.true "lists.append <list> <value> [separator]" test "$#" -eq 2 -o "$#" -eq 3
    if test -z "${1}"; then echo "${2}"; return 0; fi
    local list="${1}"
    local value="${2}"
    local separator="${3:-:}"
    if test -z "${list}"; then
        echo "${value}"
    elif lists.contains "${list}" "${value}" "${separator}"; then
        echo "${list}"
    else
        echo "${list}${separator}${value}"
    fi
}
readonly -f lists.append

# Finds the length of a list
# Arguments:
#   1. List value
#   2. The list separator, default is ':'
# Emitted value to stdout:
#   the length of the list
function lists.length() {
    assert.true "lists.length <list> [separator]" test "$#" -eq 1 -o "$#" -eq 2
    if test -z "${1}"; then echo "0"; return 0; fi
    local list="${1}"
    local separator="${2:-:}"
    lists.to_array "${list}" lists_length_tmp_arr "${separator}"
    local length="${#lists_length_tmp_arr[@]}"
    unset lists_length_tmp_arr
    echo "${length}"
}
readonly -f lists.length

# Prepends an argument to a list, but only if the list does not already
# contain the value.  If you don't care about duplicate values, then a simple
# assignment is probably a better choice than a function call.
# Arguments:
#   1. List value
#   2. The value to append
#   3. The list separator, default is ':'
# Emitted value to stdout:
#   the new list value
function lists.prepend() {
    assert.true "lists.prepend <list> <value> [separator]" test "$#" -eq 2 -o "$#" -eq 3
    if test -z "${1}"; then echo "${2}"; return 0; fi
    local list="${1}"
    local value="${2}"
    local separator="${3:-:}"
    if test -z "${list}"; then
        echo "${value}"
    elif lists.contains "${list}" "${value}" "${separator}"; then
        echo "${list}"
    else
        echo "${value}${separator}${list}"
    fi
}
readonly -f lists.prepend

# Populates an array variable with the values of a passed in list starting at
# index 0
# Arguments:
#   1. List value, default is the empty list
#   2. The name of the array variable to assign values to, does not need to
#      be defined ahead of time and any existing values will be unset
#   3. The list separator, default is ':'
# Exit codes
#   0  if the array was successfully created from the list
#   !0 otherwise
function lists.to_array() {
    assert.true "lists.to_array <list> <array variable name> [separator]" test "$#" -eq 2 -o "$#" -eq 3
    local list="${1}"
    local array_name="${2:?The name of the array variable must be specified as the 2nd argument}"
    local separator="${3:-:}"
    IFS="${separator}" read -a ${array_name} << __LIST__
${list}
__LIST__
}
readonly -f lists.to_array

# Removes a value from a list
# Arguments:
#   1. List value
#   2. Value to remove
#   2. List separator, default is ':'
# Emitted value to stdout:
#   the new list with value removed
function lists.remove() {
    assert.true "lists.remove <list> <value to remove> [separator]" test "$#" -eq 2 -o "$#" -eq 3
    if test -z "${1}"; then echo "${1}"; return 0; fi
    local list="${1}"
    local value="${2}"
    local separator="${3:-:}"
    lists.filter "${list}" "${separator}" test "${value}" !=
}
readonly -f lists.remove

# Filters a list for 'good' values only
# Arguments:
#   1. List value
#   2. List separator
#   3..* The function/program to do the filtering, plus any arguments for each
#        call.  These additional arguments are passed *before* each value in
#        list is passed in.  A list value is considered 'good' if the exit code
#        is 0 for a value, 'bad' (and filtered out) if non-zero
# Emitted value to stdout:
#   the new list with 'bad' values removed
function lists.filter() {
    assert.true "lists.filter <list> <separator> <filter function/program and arguments...>" test "$#" -ge 3
    if test -z "${1}"; then echo "${1}"; return 0; fi
    local list="${1}"
    local separator="${2}"
    shift 2
    local filter_command="$@"
    function lists.filter.reducer() {
        local accumulator="${1}"
        local list_value="${2}"
        if ${filter_command} "${list_value}"; then
            test -z "${accumulator}" && echo "${list_value}" && return 0
            echo "${accumulator}${separator}${list_value}" && return 0
        else
            echo "${accumulator}"
        fi
    }
    lists.reduce "${list}" "${separator}" "" lists.filter.reducer
}
readonly -f lists.filter

# The "map" part of map/reduce.  Transforms each value in the list by passing
# it to the given function/program
# Arguments:
#   1.   List value
#   2.   The list separator
#   4..* The map program/function, plus any additional arguments to be
#        passed for each call.  These additional arguments are passed *before*
#        the list value
function lists.map() {
    assert.true "lists.map <list> <separator> <mapping function/program and arguments...>" test "$#" -ge 3
    if test -z "${1}"; then echo "${1}"; return 0; fi
    local list="${1}"
    local separator="${2}"
    shift 2
    local map_command="$@"
    function lists.map.reducer() {
        local accumulator="${1}"
        local list_value="${2}"
        test -z "${accumulator}" && ${map_command} "${list_value}" && return 0
        echo "${accumulator}${separator}$(${map_command} "${list_value}")"
    }
    lists.reduce "${list}" "${separator}" "" lists.map.reducer
}
readonly -f lists.map

# The "reduce" part of map/reduce.  Reduces a list to a single value using the
# passed in command/function.  The seed value is the starting value, it is the
# default value if an empty list is passed.
# Arguments:
#   1.   List value
#   2.   The list separator
#   3.   The seed value
#   4..* The reduce program/function, plus any additional arguments to be
#        passed for each call.  These additional arguments are passed *before*
#        the seed/accumulated value and the next list value
function lists.reduce() {
    assert.true "lists.reduce <list> <separator> <seed value> <reduce function/program and arguments...>" test "$#" -ge 4
    if test -z "${1}"; then echo "${3}"; return 0; fi
    local list="${1}"
    local separator="${2}"
    local accumulator="${3}"
    shift 3
    lists.to_array "${list}" lists_reduce_arr_tmp "${separator}"
    for list_value in "${lists_reduce_arr_tmp[@]}"
    do
        accumulator=$("$@" "${accumulator}" "${list_value}")
    done
    unset lists_reduce_arr_tmp
    echo "${accumulator}"
}
readonly -f lists.reduce

# Executes the passed in command/function for each value in the list, passing
# in each list value as the sole argument.
# Arguments:
#   1.   List value
#   2.   The list separator
#   3..* The program/function for each list value, plus any additional arguments
#        to be passed for each call.  These additional arguments are passed
#        *before* the list value
# Exit codes
#   0 if all executions exited with code 0
#   1 if one or more executions did not exit with code 0
function lists.foreach() {
    assert.true "lists.foreach <list> <separator> <function/program and arguments...>" test "$#" -ge 3
    test -z "${1}" && return 0
    local list="${1}"
    local separator="${2}"
    shift 2
    lists.to_array "${list}" lists_foreach_arr_tmp "${separator}"
    let local rv=0
    for list_value in "${lists_foreach_arr_tmp[@]}"
    do
        if ! "$@" "${list_value}"; then
            let rv=1
        fi
    done
    unset lists_foreach_arr_tmp
    return "${rv}"
}
readonly -f lists.foreach

# Like lists.foreach() except that it short-circuits as soon as the first
# success is found.
# Arguments:
#   1.   List value
#   2.   The list separator
#   3..* The program/function for each list value, plus any additional arguments
#        to be passed for each call.  These additional arguments are passed
#        *before* the list value
# Exit codes
#   0 if any execution exited with code 0
#   1 if no executions exited with code 0
function lists.any() {
    assert.true "lists.any <list> <separator> <function/program and arguments...>" test "$#" -ge 3
    test -z "${1}" && return 0
    local list="${1}"
    local separator="${2}"
    shift 2
    lists.to_array "${list}" lists_foreach_arr_tmp "${separator}"
    for list_value in "${lists_foreach_arr_tmp[@]}"
    do
        "$@" "${list_value}" && return 0
    done
    unset lists_foreach_arr_tmp
    return 1
}
readonly -f lists.any

# Reverses a list
# Arguments:
#   1. List value
#   2. List separator, default is ':'
# Emitted value to stdout:
#   list with elements in reverse
function lists.reverse() {
    assert.true "lists.reverse <list> [separator]" test "$#" -eq 1 -o "$#" -eq 2
    if test -z "${1}"; then echo "${1}"; return 0; fi
    local list="${1}"
    local separator="${2}"
    function lists.reverse.reducer() {
        local accumulator="${1}"
        local list_value="${2}"
        test -z "${accumulator}" && echo "${list_value}" && return 0
        echo "${list_value}${separator}${accumulator}"
    }
    lists.reduce "${list}" "${separator}" "" lists.reverse.reducer
}
readonly -f lists.reverse

$(bvn.load_plugin baven assert 1.0.0)
