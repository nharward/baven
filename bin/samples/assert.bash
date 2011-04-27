#! /bin/bash

#BAVEN_DEBUG=yes
#BAVEN_VERBOSE=yes

source $(dirname "${0}")/../baven.bash
$(bvn.load_plugin baven assert 1.0.0)

if bvn.is_plugin_loaded baven assert 1.0.0; then
    assert.true "/bin/true should be a good assertion" /bin/true
    assert.true "Multi-arg programs should work, too" test -x "$(which bash)"
    assert.false "/bin/false should be a [good] false assertion" /bin/false
    assert.false "Multi-arg programs should work, too" test -f /

    assert.equals "Empty values should be equal" "" ""
    assert.equals "Non-empty values should be equal" "Hello, world!" "Hello, world!"

    assert.not_equals "Differing values should not be equal" "" "Hello, world!"
    assert.not_equals "Empty values should be equal" "Hello, world!" ""

    assert.true "If you see this error in a stack trace, asserts work!" /bin/false
else
    bvn.err "Could not load assert plugin"
    exit 1
fi
