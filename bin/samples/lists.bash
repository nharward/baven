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

    # Length
    assert.equals "list[].length() == 0" '0' "$(lists.length '')"
    assert.equals "list[1,2,3].length() == 3" '3' "$(lists.length '1,2,3' ',')"
    assert.equals "list[a=b=c=d=e=f=g].length() == 7" '7' "$(lists.length 'a=b=c=d=e=f=g' '=')"

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

    lists.to_array "" testarr
    assert.equals 'Array length should be 0' '0' "${#testarr[@]}"

    # Remove
    assert.equals 'Should be empty' '' "$(lists.remove '' '')"
    assert.equals 'Should be 10:9:8:7:6:4:3:2:1' '10:9:8:7:6:4:3:2:1' "$(lists.remove '10:9:8:7:6:5:4:3:2:1' '5')"
    assert.equals 'Should be A;B;C;D;E;F' 'A;B;C;D;E;F' "$(lists.remove 'A;B;C;D;E;F' 'Z' ';')"
    assert.equals 'Should be Hello, world!' 'Hello, world!' "$(lists.remove 'Hello,goodbye, world!' 'goodbye' ',')"

    # Foreach
    lists.foreach '1,2,3' ',' true
    assert.equals 'Should have exit code 0' '0' "${?}"
    lists.foreach '1,2,3' ',' false
    assert.equals 'Should have exit code 1' '1' "${?}"
    lists.foreach '1,2,3' ',' test 4 -ne
    assert.equals 'Should have exit code 0' '0' "${?}"
    lists.foreach '1,2,3' ',' test 2 -ne
    assert.equals 'Should have exit code 1' '1' "${?}"

    # Filter
    assert.equals 'Should be 2' '2' "$(lists.filter '1.2.3' '.' test '2' -eq)"
    assert.equals 'Should be 1.2.3.4' '1.2.3.4' "$(lists.filter '1.2.3.4.5.6.7.8.9.10' '.' test '5' -gt)"
    assert.equals 'Should be empty' '' "$(lists.filter '1;2;3' ';' false)"
    assert.equals 'Should be 1;2;3' '1;2;3' "$(lists.filter '1;2;3' ';' true)"

    # Map
    function double()      { echo "$((${1}*2))"; }
    function odd_or_even()      { test $((${1}%2)) -eq 0 && echo "even" && return 0; echo "odd"; }
    function to_upper()      { echo "${1}" | tr '[a-z]' '[A-Z]' ; }
    assert.equals 'Should be 20406' '20406' "$(lists.map '10203' '0' double)"
    assert.equals 'Should be odd_even_odd_even' 'odd_even_odd_even' "$(lists.map '1_2_3_4' '_' odd_or_even)"
    assert.equals 'Should be HELLO, WORLD!' 'HELLO, WORLD!' "$(lists.map 'hello, world!' ':' to_upper)"

    # Reduce
    function add()      { echo $((${1}+${2})); }
    function subtract() { echo $((${1}-${2})); }
    function concat()   { echo "${1}${2}"; }
    assert.equals 'Should be 6' '6' "$(lists.reduce '1.2.3' '.' 0 add)"
    assert.equals 'Should be -26' '-26' "$(lists.reduce '10|1|35' '|' 20 subtract)"
    assert.equals 'Should be abcdef' 'abcdef' "$(lists.reduce 'a/b/c/d/e/f' '/' '' concat)"

    # Any
    lists.any '1,2,3' ',' true
    assert.equals 'Should have exit code 0' '0' "${?}"
    lists.any '1,2,3' ',' false
    assert.equals 'Should have exit code 1' '1' "${?}"
    lists.any '1,2,3' ',' test 4 -eq
    assert.equals 'Should have exit code 1' '1' "${?}"
    lists.any '1,2,3' ',' test 4 -ne
    assert.equals 'Should have exit code 0' '0' "${?}"
    lists.any '1,2,3' ',' test 2 -eq
    assert.equals 'Should have exit code 0' '0' "${?}"

    # Reverse
    assert.equals 'Should be empty' '' "$(lists.reverse '')"
    assert.equals 'Should be abcdef' 'abcdef' "$(lists.reverse 'abcdef')"
    assert.equals 'Should be 3;2;1' '3;2;1' "$(lists.reverse '1;2;3' ';')"
    assert.equals 'Should be 1;2;3' '1;2;3' "$(lists.reverse '3;2;1' ';')"
    assert.equals 'Should be f/e/d/c/b/a' 'f/e/d/c/b/a' "$(lists.reverse 'a/b/c/d/e/f' '/')"
else
    bvn.err "Could not load assert plugin"
    exit 1
fi
