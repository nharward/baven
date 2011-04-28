#! /bin/bash

#BAVEN_DEBUG=yes
#BAVEN_VERBOSE=yes

source $(dirname "${0}")/../baven.bash
$(bvn.load_plugin baven lists 1.0.0)
$(bvn.load_plugin baven assert 1.0.0)

if bvn.is_plugin_loaded baven lists 1.0.0 && bvn.is_plugin_loaded baven lists 1.0.0; then
    # Contains
    assert.true "list[1,2,3].contains(1)" lists.contains '1,2,3' '1' ','
    assert.true "list[1,2,3].contains(2)" lists.contains '1,2,3' '2' ','
    assert.true "list[1,2,3].contains(3)" lists.contains '1,2,3' '3' ','
    assert.false "! list[1,2,3].contains(4)" lists.contains '1,2,3' '4' ','
    assert.false "list[hello again;there].contains(hello)" lists.contains 'hello again;there' 'hello' ';'

    # Append
    assert.equals "append to empty list" 'hello' "$(lists.append '' 'hello')"
    assert.equals "append to single-element list" 'hello$goodbye' "$(lists.append 'hello' 'goodbye' '$')"
    assert.equals "append to multi-element list" 'hello$goodbye$hello again' "$(lists.append 'hello' 'goodbye$hello again' '$')"
    assert.equals "append existing value doesn't change the list" "hello|goodbye|again" "$(lists.append 'hello|goodbye|again' 'goodbye' '|')"

    # Prepend
    assert.equals "prepend to empty list" 'hello' "$(lists.prepend '' 'hello')"
    assert.equals "prepend to single-element list" 'hello;goodbye' "$(lists.prepend 'goodbye' 'hello' ';')"
    assert.equals "prepend to multi-element list" 'hello.goodbye.hello again' "$(lists.prepend 'goodbye.hello again' 'hello' '.')"
    assert.equals "prepend existing value doesn't change the list" 'hello.goodbye.again' "$(lists.prepend 'hello.goodbye.again' 'goodbye' '.')"

    # To_array
    lists.to_array '1,2,3' testarr ','
    assert.equals "Array length should be 3" '3' "${#testarr[@]}"
    assert.equals 'Array[0] should be "1"' '1' "${testarr[0]}"
    assert.equals 'Array[1] should be "2"' '2' "${testarr[1]}"
    assert.equals 'Array[2] should be "3"' '3' "${testarr[2]}"

    lists.to_array "a:b::c:d" testarr
    assert.equals "Array length should be 5" '5' "${#testarr[@]}"
    assert.equals 'Array[0] should be "a"' 'a' "${testarr[0]}"
    assert.equals 'Array[1] should be "b"' 'b' "${testarr[1]}"
    assert.equals 'Array[2] should be empty' '' "${testarr[2]}"
    assert.equals 'Array[3] should be "c"' 'c' "${testarr[3]}"
    assert.equals 'Array[5] should be "d"' 'd' "${testarr[4]}"

    # Filter
    assert.equals 'Should be 2' '2' "$(lists.filter '1.2.3' '.' test '2' -eq)"
    assert.equals 'Should be 1.2.3.4' '1.2.3.4' "$(lists.filter '1.2.3.4.5.6.7.8.9.10' '.' test '5' -gt)"
    assert.equals 'Should be empty' '' "$(lists.filter '1;2;3' ';' /bin/false)"
    assert.equals 'Should be 1;2;3' '1;2;3' "$(lists.filter '1;2;3' ';' /bin/true)"

    # Reduce
    function add()      { echo $((${1}+${2})); }
    function subtract() { echo $((${1}-${2})); }
    function concat()   { echo "${1}${2}"; }
    assert.equals 'Should be 6' '6' "$(lists.reduce '1.2.3' '.' 0 add)"
    assert.equals 'Should be -26' '-26' "$(lists.reduce '10|1|35' '|' 20 subtract)"
    assert.equals 'Should be abcdef' 'abcdef' "$(lists.reduce 'a/b/c/d/e/f' '/' '' concat)"
else
    bvn.err "Could not load assert plugin"
    exit 1
fi
