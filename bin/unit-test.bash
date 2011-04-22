#! /bin/bash -x

BAVEN_DEBUG=yes
BAVEN_VERBOSE=yes

source $(dirname "${0}")/baven.bash
$(bvn.load_plugin baven unit-test 0.1.0)

bvn.is_plugin_loaded baven unit-test 0.1.0
exit $?
