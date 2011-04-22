#! /bin/bash

#BAVEN_DEBUG=yes
#BAVEN_VERBOSE=yes

source $(dirname "${0}")/../baven.bash
$(bvn.load_plugin baven ansi-color 1.0.0)

if bvn.is_plugin_loaded baven ansi-color 1.0.0; then
    cat <<__COLOR_DEMO__
Standout  : $(color.standout "Hello, world!")
Underline : $(color.underline "Hello, world!")
Dim       : $(color.dim "Hello, world!")
Black     : $(color.black "Hello, world!")
Red       : $(color.red "Hello, world!")
Green     : $(color.green "Hello, world!")
Yellow    : $(color.yellow "Hello, world!")
Blue      : $(color.blue "Hello, world!")
Magenta   : $(color.magenta "Hello, world!")
Cyan      : $(color.cyan "Hello, world!")
White     : $(color.white "Hello, world!")
__COLOR_DEMO__
else
    bvn.err "Could not load ANSI color plugin"
    exit 1
fi
