#! /bin/bash

# If you really want/need to, BAVEN_LOCAL, BAVEN_CONF and BAVEN_REPO can be
# set before sourcing this file if you don't like the defaults
BAVEN_LOCAL="${BAVEN_LOCAL:-${HOME}/.baven}"
BAVEN_CONF="${BAVEN_CONF:-${BAVEN_LOCAL}/baven-conf.bash}"
BAVEN_REPO="${BAVEN_REPO:-${BAVEN_LOCAL}/repository}"

# Setting these to empty/non-empty values any time during execution controls
# debug/verbose output
BAVEN_DEBUG="${BAVEN_DEBUG:-}"
BAVEN_VERBOSE="${BAVEN_VERBOSE:-}"

# Saves a list of loaded modules
declare -A baven_plugins

# Initializes Baven to have a sane state if starting from scratch
function bvn.init() {
    test -d "${BAVEN_LOCAL}" || bvn.exec_or_fail mkdir -p "${BAVEN_LOCAL}"
    test -f "${BAVEN_CONF}"  || { bvn.exec_or_fail touch "${BAVEN_CONF}"
                                  bvn.exec_or_fail echo "declare -a baven_repositories=(\"https://github.com/nharward/baven/raw/master/repository\")" > "${BAVEN_CONF}"
                                }
    test -d "${BAVEN_REPO}" || bvn.exec_or_fail mkdir -p "${BAVEN_REPO}"
    echo "eval source '${BAVEN_CONF}'"
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
    "$@"
    if test "$?" != 0; then
        bvn.err "Execution of [$@] failed"
        exit 1
    fi
}
readonly -f bvn.exec_or_fail

# Fetches and spits to stdout the content of a given URL
# Arguments:
#   1. The URL to fetch
# Emitted return value to stdout:
#   the URL content
# Function return value:
#   0 on success
#   255 when no available program to download content
#   Other unsuccessful codes dependent on which method was used to download (wget, curl, etc.)
function bvn.get_url_content() {
    local url="${1:?URL must be specified}"
    local fetch_cmd=""
    test -z "${fetch_cmd}" && test -x "$(which "curl")"   && fetch_cmd="$(which "curl") -s"
    test -z "${fetch_cmd}" && test -x "$(which "wget")"   && fetch_cmd="$(which "wget") -q -O -"
    test -z "${fetch_cmd}" && test -x "$(which "w3m")"    && fetch_cmd="$(which "w3m") -dump_source"
    test -z "${fetch_cmd}" && test -x "$(which "links")"  && fetch_cmd="$(which "links") -source"
    test -z "${fetch_cmd}" && test -x "$(which "elinks")" && fetch_cmd="$(which "elinks") -source 1"
    test -z "${fetch_cmd}" && test -x "$(which "lynx")"   && fetch_cmd="$(which "lynx") -source"
    if test -n "${fetch_cmd}"; then
        ${fetch_cmd} "${url}"
        return $?
    else
        bvn.err "Unable to retrieve URL[${1}] content: no wget/curl/w3m/[e]links/lynx/etc. available"
        return 255
    fi
}
readonly -f bvn.get_url_content

# Finds a module either locally or, if not found, from network repositories (and then caches locally)
# Arguments:
#   1. plugin package [required]
#   2. plugin name    [required]
#   3. plugin version [required]
# Emitted return value to stdout:
#   the fully qualified path on disk if found, or nothing if not
function bvn.private_fetch_and_cache_plugin() {
    local package="${1:?Plugin package must be specified}"
    local name="${2:?Plugin name must be specified}"
    local version="${3:?Plugin version must be specified}"
    local plugin_path="${package//.//}/${name}/${name}-${version}.bash"
    local cached_path="${BAVEN_REPO}/${plugin_path}"
    if test -f "${cached_path}"; then
        echo "${cached_path}"
        return 0
    else
        if test \! -d "$(dirname ${cached_path})"; then
            mkdir -p "$(dirname ${cached_path})" || { bvn.err "Unable to create repository structure for plugin ${cached_path}" && return 1 ; }
        fi
        for bvn_remote_repo in "${baven_repositories[@]}"
        do
            local url="${bvn_remote_repo}/${plugin_path}"
            bvn.get_url_content "${url}" > "${cached_path}.tmp"
            if test "$?" = 0; then
                mv "${cached_path}.tmp" "${cached_path}"
                echo "${cached_path}"
                return 0
            else
                rm -f "${cached_path}.tmp"
            fi
        done
        return 1
    fi
}
readonly -f bvn.private_fetch_and_cache_plugin

# Loads a plugin, checking local cache first.  *Must be invoked* in the following way:
#   `bvn.load_plugin plugin.package.name plugin.name plugin.version`
#      or
#   $(bvn.load_plugin plugin.package.name plugin.name plugin.version)
#   See the invocation of "bvn.init" at the bottom of this script for an example
# Arguments:
#   1. plugin package [required]
#   2. plugin name    [required]
#   3. plugin version [required]
function bvn.load_plugin() {
    bvn.is_plugin_loaded "$@" && return 0
    local plugin_local_path=$(bvn.private_fetch_and_cache_plugin "$@")
    test -f "${plugin_local_path}" && echo "eval source '${plugin_local_path}' && baven_plugins[\"${1}:${2}\"]=\"${3}\"" && return 0
    echo "bvn.err Plugin[${1}:${2}:${3}] not found" && return 1
}
readonly -f bvn.load_plugin

# Returns 0 if the plugin is loaded, 1 if not
# Arguments:
#   1. plugin package [required]
#   2. plugin name    [required]
#   3. plugin version [required]
function bvn.is_plugin_loaded() {
    local package="${1:?Plugin package must be specified}"
    local name="${2:?Plugin name must be specified}"
    local version="${3:?Plugin version must be specified}"
    test "${baven_plugins[${package}:${name}]}" = "${version}" && return 0
    return 1
}
readonly -f bvn.is_plugin_loaded

$(bvn.init)
baven_plugins["baven:bootstrap"]="0.0.1"
