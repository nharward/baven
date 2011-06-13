# Opposite of xargs; takes all command line arguments and prints
# them out in order to stdout, one per line
function core.sgrax() {
    for arg in "$@"; do
        echo "${arg}"
    done
}
readonly -f core.sgrax
