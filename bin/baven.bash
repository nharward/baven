#! /bin/bash

# If you really want/need to, BAVEN_LOCAL, BAVEN_CONF and BAVEN_REPO can be
# set before sourcing this file if you don't like the defaults
BAVEN_LOCAL="${BAVEN_LOCAL:-${HOME}/.baven}"
BAVEN_CONF="${BAVEN_CONF:-${BAVEN_LOCAL}/conf.bash}"
BAVEN_REPO="${BAVEN_REPO:-${BAVEN_LOCAL}/repository}"

BAVEN_DEBUG="${BAVEN_DEBUG:-}"
BAVEN_VERBOSE="${BAVEN_VERBOSE:-}"

# Initializes Baven to have a sane state if starting from scratch
function bvn.init() { echo eval '
    test -d "${BAVEN_LOCAL}" || bvn.exec_or_fail mkdir -p "${BAVEN_LOCAL}" ;
    test -f "${BAVEN_CONF}"  || { bvn.exec_or_fail touch "${BAVEN_CONF}" ;
                                  bvn.exec_or_fail echo "readonly repositories=(\"https://github.com/nharward/baven/raw/master/repository\")" > "${BAVEN_CONF}" ;
                                } ;
    test -d "${BAVEN_REPO}" || bvn.exec_or_fail mkdir -p "${BAVEN_REPO}" ;
    source "${BAVEN_CONF}" ;'
}
readonly -f bvn.init

# Prints the arguments with a leading "[INFO]" if $VERBOSE is set
function bvn.verbose() {
    test -n "${BAVEN_VERBOSE}" && echo "[INFO]" "$@"
}
readonly -f bvn.verbose

# Prints the arguments with a leading "[DEBUG]" if $DEBUG is set
function bvn.debug() {
    test -n "${BAVEN_DEBUG}" && echo "[DEBUG]" "$@"
}
readonly -f bvn.debug

# Prints the arguments to stderr instead of stdout
function bvn.err() {
    echo >&2 "$@"
}
readonly -f bvn.err

# Runs all arguments as a command, failing the script if the command fails
function bvn.exec_or_fail() {
    bvn.debug "Running command '$@'"
    "$@"
    if test "$?" != 0; then
        bvn.err "Execution of [$@] failed"
        exit 1
    fi
}
readonly -f bvn.exec_or_fail

# Loads a module, checking local cache first
# Arguments:
#   1. plugin package [required]
#   2. plugin name    [required]
#   3. plugin version [required]
function bvn.load_plugin() {
    readonly local package="${1:?Plugin package must be specified}"
    readonly local name="${2:?Plugin name must be specified}"
    readonly local version="${3:?Plugin version must be specified}"
    readonly local plugin_path="${package//.//}/${name}/${name}-${version}.bash"
    echo eval '
    bvn.debug "load_plugin() called ['"${package}/${name}/${version}"'], plugin relative path ['"${plugin_path}"']" ;
    bvn.debug "Checking for local plugin['"${BAVEN_REPO}/${plugin_path}"']" ;
    if test -f "'"${BAVEN_REPO}/${plugin_path}"'"; then
        bvn.debug "Plugin['"${plugin_path}"'] found in local cache" ;
        source "'"${BAVEN_REPO}/${plugin_path}"'" ;
        bvn.verbose "Plugin['"${plugin_path}"'] loaded from local cache" ;
    else
        bvn.debug "Plugin['"${plugin_path}"'] not in local cache, checking configured repositories" ;
        for bvn_remote_repo in '"${repositories[@]}"' ;
        do
            bvn.debug "Checking for remote plugin[${bvn_remote_repo}/'"${plugin_path}"']" ;
        done ;
    fi ; '
}
readonly -f bvn.load_plugin

$(bvn.init)
