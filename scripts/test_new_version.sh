#!/bin/bash

source ./new_version.sh

#pass_count=0
#fail_count=0
#
#run_test() {
#  local desc="$1"
#  local expected="$2"
#  shift 2
#  local output
#  output=$(new_version "$@" 2>&1)
#
#  if [[ "$output" == "$expected" ]]; then
#    echo "✅ PASS: $desc"
#    ((pass_count++))
#  else
#    echo "❌ FAIL: $desc"
#    echo "   → Expected: '$expected'"
#    echo "   → Got:      '$output'"
#    ((fail_count++))
#  fi
#}

run_test() {
  local desc="$1"
  local expected="$2"
  shift 2
  local params=("$@")

  echo "----"
  echo "Test: $desc"
  echo "Input params: ${params[*]}"

  local output
  output=$(new_version "${params[@]}" 2>&1)
  local status=$?

  echo "Output: $output"
  echo "Expected: $expected"

  if [[ $status -ne 0 ]]; then
    # Se a função retornou erro, comparamos saída de erro
    if [[ "$output" == "$expected" ]]; then
      echo "✅ PASS (error)"
      ((pass_count++))
    else
      echo "❌ FAIL"
      ((fail_count++))
    fi
  else
    # Se a função retornou sucesso, comparamos saída normal
    if [[ "$output" == "$expected" ]]; then
      echo "✅ PASS"
      ((pass_count++))
    else
      echo "❌ FAIL"
      ((fail_count++))
    fi
  fi
}

# Test cases
run_test "Increment major version" "2.0.0" main 1.2.3 major
run_test "Increment minor version" "1.3.0" main 1.2.3 minor
run_test "Increment patch version" "1.2.4" main 1.2.3 patch

run_test "Add db.1 on main" "1.2.3-db.1" main 1.2.3 buildnumber
run_test "Increment db buildnumber" "1.2.3-db.2" main 1.2.3-db.1 buildnumber

run_test "Add rc.1 on release" "1.2.3-rc.1" release/1.2 1.2.3 buildnumber
run_test "Increment rc buildnumber" "1.2.3-rc.6" release/1.2 1.2.3-rc.5 buildnumber

run_test "Invalid suffix on main" "Error: invalid suffix 'rc' for branch 'main'" main 1.2.3-rc.1 buildnumber
run_test "Invalid suffix on release" "Error: invalid suffix 'db' for branch 'release/1.2'" release/1.2 1.2.3-db.1 buildnumber

run_test "Invalid branch name" "Error: invalid branch 'feature/xyz'" feature/xyz 1.2.3 major
run_test "Invalid version format" "Error: invalid version format 'abc'" main abc patch
run_test "Invalid operator" "Error: invalid operator 'foo'" main 1.2.3 foo

run_test "Release removes suffix" "1.2.3" main 1.2.3-db.5 release
echo "Finished all tests"
echo
echo "🎯 Tests passed: $pass_count"
echo "❌ Tests failed: $fail_count"

exit $((fail_count > 0 ? 1 : 0))
