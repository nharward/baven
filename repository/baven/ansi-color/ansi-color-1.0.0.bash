# Set up ANSI color formatting
# If either the 'tput' command is not available or the current terminal
# (based on the "TERM" env variable) does not support colors, then all
# color functions simply echo their arguments
if test -x "$(which tput)"; then
    BVN_COLOR_STNDOUT_BEGIN="$(tput "-T${TERM:-dumb}" smso)"
    BVN_COLOR_STNDOUT_END="$(tput "-T${TERM:-dumb}" rmso)"
    BVN_COLOR_UNDERLINE_BEGIN="$(tput "-T${TERM:-dumb}" smul)"
    BVN_COLOR_UNDERLINE_END="$(tput "-T${TERM:-dumb}" rmul)"
    BVN_COLOR_DIM_BEGIN="$(tput "-T${TERM:-dumb}" dim)"
    BVN_COLOR_DIM_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_BLACK_BEGIN="$(tput "-T${TERM:-dumb}" setaf 0)"
    BVN_COLOR_BLACK_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_RED_BEGIN="$(tput "-T${TERM:-dumb}" setaf 1)"
    BVN_COLOR_RED_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_GREEN_BEGIN="$(tput "-T${TERM:-dumb}" setaf 2)"
    BVN_COLOR_GREEN_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_YELLOW_BEGIN="$(tput "-T${TERM:-dumb}" setaf 3)"
    BVN_COLOR_YELLOW_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_BLUE_BEGIN="$(tput "-T${TERM:-dumb}" setaf 4)"
    BVN_COLOR_BLUE_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_MAGENTA_BEGIN="$(tput "-T${TERM:-dumb}" setaf 5)"
    BVN_COLOR_MAGENTA_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_CYAN_BEGIN="$(tput "-T${TERM:-dumb}" setaf 6)"
    BVN_COLOR_CYAN_END="$(tput "-T${TERM:-dumb}" sgr0)"
    BVN_COLOR_WHITE_BEGIN="$(tput "-T${TERM:-dumb}" setaf 7)"
    BVN_COLOR_WHITE_END="$(tput "-T${TERM:-dumb}" sgr0)"
fi

# Wraps arguments in TTY "standout" mode
function color.standout() {
    echo "${BVN_COLOR_STNDOUT_BEGIN}$@${BVN_COLOR_STNDOUT_END}"
}
readonly -f color.standout

# Wraps arguments in TTY "underline" mode
function color.underline() {
    echo "${BVN_COLOR_UNDERLINE_BEGIN}$@${BVN_COLOR_UNDERLINE_END}"
}
readonly -f color.underline

# Wraps arguments in TTY "dim" mode
function color.dim() {
    echo "${BVN_COLOR_DIM_BEGIN}$@${BVN_COLOR_DIM_END}"
}
readonly -f color.dim

# Colorizes the arguments to a black foreground on ANSI-capable TTYs
function color.black() {
    echo "${BVN_COLOR_BLACK_BEGIN}$@${BVN_COLOR_BLACK_END}"
}
readonly -f color.black

# Colorizes the arguments to a red foreground on ANSI-capable TTYs
function color.red() {
    echo "${BVN_COLOR_RED_BEGIN}$@${BVN_COLOR_RED_END}"
}
readonly -f color.red

# Colorizes the arguments to a green foreground on ANSI-capable TTYs
function color.green() {
    echo "${BVN_COLOR_GREEN_BEGIN}$@${BVN_COLOR_GREEN_END}"
}
readonly -f color.green

# Colorizes the arguments to a yellow foreground on ANSI-capable TTYs
function color.yellow() {
    echo "${BVN_COLOR_YELLOW_BEGIN}$@${BVN_COLOR_YELLOW_END}"
}
readonly -f color.yellow

# Colorizes the arguments to a blue foreground on ANSI-capable TTYs
function color.blue() {
    echo "${BVN_COLOR_BLUE_BEGIN}$@${BVN_COLOR_BLUE_END}"
}
readonly -f color.blue

# Colorizes the arguments to a magenta foreground on ANSI-capable TTYs
function color.magenta() {
    echo "${BVN_COLOR_MAGENTA_BEGIN}$@${BVN_COLOR_MAGENTA_END}"
}
readonly -f color.magenta

# Colorizes the arguments to a cyan foreground on ANSI-capable TTYs
function color.cyan() {
    echo "${BVN_COLOR_CYAN_BEGIN}$@${BVN_COLOR_CYAN_END}"
}
readonly -f color.cyan

# Colorizes the arguments to a white foreground on ANSI-capable TTYs
function color.white() {
    echo "${BVN_COLOR_WHITE_BEGIN}$@${BVN_COLOR_WHITE_END}"
}
readonly -f color.white
