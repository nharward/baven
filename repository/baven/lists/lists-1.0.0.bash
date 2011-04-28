# Tests whether a given value exists in a list
# Arguments (all are optional):
#   1. List value (for example $PATH), default is the empty list
#   2. The value to test for (say /usr/bin), default is an empty value
#   3. The list separator, default is ':'
# Exit codes
#   0   If the value is contained in the list
#   !0  If the value is not in the list
function lists.contains() {
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
# contain the value
# Arguments (all are optional):
#   1. List value (for example $PATH), default is the empty list
#   2. The value to append (say /my/app/bin), default is an empty value
#   3. The list separator, default is ':'
# Emitted value to stdout:
#   the new list value
function lists.append() {
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

# Prepends an argument to a list, but only if the list does not already
# contain the value
# Arguments (all are optional):
#   1. List value (for example $PATH), default is the empty list
#   2. The value to append (say /my/app/bin), default is an empty value
#   3. The list separator, default is ':'
# Emitted value to stdout:
#   the new list value
function lists.prepend() {
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

# Populates an array variable with the values of a passed in list, starting at
# index 0
# Arguments (all are optional):
#   1. List value, default is the empty list
#   2. The name of the array variable to assign values to, does not need to
#      be defined ahead of time and any existing values will be unset
#   3. The list separator, default is ':'
function lists.to_array() {
    local list="${1}"
    local array_name="${2:?The name of the array variable must be specified as the 2nd argument}"
    local separator="${3:-:}"
    IFS="${separator}" read -a ${array_name} << __LIST__
${list}
__LIST__
}
readonly -f lists.to_array

# TODO:
#   lists.remove
#   lists.filter
#   lists.map
#   lists.reduce
#   lists.foreach

$(bvn.load_plugin baven assert 1.0.0)
assert.true "egrep is required to use the lists plugin, please check your path" test -x "$(which egrep)"
