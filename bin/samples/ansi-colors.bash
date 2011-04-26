#! /bin/bash

#BAVEN_DEBUG=yes
#BAVEN_VERBOSE=yes

source $(dirname "${0}")/../baven.bash
$(bvn.load_plugin baven ansi-color 1.0.0)

if bvn.is_plugin_loaded baven ansi-color 1.0.0; then
    cat <<__COLOR_DEMO__
Standout  : $(ansi-color.standout "Hello, world!")
Underline : $(ansi-color.underline "Hello, world!")
Dim       : $(ansi-color.dim "Hello, world!")
Black     : $(ansi-color.black "Hello, world!")
Red       : $(ansi-color.red "Hello, world!")
Green     : $(ansi-color.green "Hello, world!")
Yellow    : $(ansi-color.yellow "Hello, world!")
Blue      : $(ansi-color.blue "Hello, world!")
Magenta   : $(ansi-color.magenta "Hello, world!")
Cyan      : $(ansi-color.cyan "Hello, world!")
White     : $(ansi-color.white "Hello, world!")
__COLOR_DEMO__
else
    bvn.err "Could not load ANSI color plugin"
    exit 1
fi
