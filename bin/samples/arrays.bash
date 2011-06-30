#! /bin/bash

#BAVEN_DEBUG=yes
#BAVEN_VERBOSE=yes

source $(dirname "${0}")/../baven.bash
$(bvn.load_plugin baven assert 1.0.0)
$(bvn.load_plugin baven arrays 1.0.0)

#if bvn.is_plugin_loaded baven assert 1.0.0 && bvn.is_plugin_loaded baven arrays 1.0.0; then
if bvn.is_plugin_loaded baven assert 1.0.0; then
    # Some data to work with
    my_array=(one two three "three and a half" four five)

    # Contains
    assert.true "array(${my_array[*]}).contains(one)" arrays.contains my_array 'one'
    assert.true "array(${my_array[*]}).contains(two)" arrays.contains my_array 'two'
    assert.true "array(${my_array[*]}).contains(three)" arrays.contains my_array 'three'
    assert.true "array(${my_array[*]}).contains(three and a half)" arrays.contains my_array 'three and a half'
    assert.true "array(${my_array[*]}).contains(four)" arrays.contains my_array 'four'
    assert.true "array(${my_array[*]}).contains(five)" arrays.contains my_array 'five'
    assert.false "! array(${my_array[*]}).contains(six)" arrays.contains my_array 'six'
    assert.false "! array(${my_array[*]}).contains(0)" arrays.contains my_array '0'
    assert.false "! array(${my_array[*]}).contains(1)" arrays.contains my_array '1'

    # To_list
    assert.equals "array(<empty>).to_list('|') == ''" "" "$(arrays.to_list not_my_array '|')"
    assert.equals "array(${my_array[*]}).to_list('|') == one|two|three|three and a half|four|five" "one|two|three|three and a half|four|five" "$(arrays.to_list my_array '|')"

    # Any
    arrays.any my_array true
    assert.equals 'Should have exit code 0' '0' "${?}"
    arrays.any my_array false
    assert.equals 'Should have exit code 1' '1' "${?}"
    arrays.any my_array test 4 =
    assert.equals 'Should have exit code 1' '1' "${?}"
    arrays.any my_array test 4 !=
    assert.equals 'Should have exit code 0' '0' "${?}"
    arrays.any my_array test 'two' =
    assert.equals 'Should have exit code 0' '0' "${?}"
    exit 0

    # All
    arrays.all my_array test 'six' !=
    assert.equals 'Should have exit code 0' '0' "${?}"
    arrays.all my_array test 'three and a half' !=
    assert.equals 'Should have exit code 1' '1' "${?}"
else
    bvn.err "Could not load assert and/or arrays plugins"
    exit 1
fi
