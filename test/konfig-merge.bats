#!/usr/bin/env bats

# Copyright 2019 Cornelius Weig
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

COMMAND="$BATS_TEST_DIRNAME/../konfig-merge"

load common

####  HELP

@test "help should not fail" {
  run ${COMMAND} help
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "USAGE"* ]]
}

@test "--help should not fail" {
  run ${COMMAND} --help
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "USAGE"* ]]
}

@test "-h should not fail" {
  run ${COMMAND} -h
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "USAGE"* ]]
}

@test "no arguments given" {
  run ${COMMAND}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "USAGE"* ]]
}

####  MERGE

@test "merge --preserve-structure: three configs" {
  run ${COMMAND} merge --preserve-structure testdata/config{1,2,3}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123' "$output") = 'same' ]]
}

@test "merge -p: not enough arguments" {
  run ${COMMAND} merge -p testdata/config1
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "error: not enough arguments"* ]]
}

@test "vanilla merge: three configs" {
  run ${COMMAND} merge testdata/config{1,2,3}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123-flat' "$output") = 'same' ]]
}

@test "vanilla merge: single config" {
  run ${COMMAND} merge testdata/config123
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123-flat' "$output") = 'same' ]]
}

####  IMPORT

@test "import single config" {
  use_config config123
  run ${COMMAND} import testdata/config2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12' "$output") = 'same' ]]
}

@test "import multiple configs" {
  use_config config123
  run ${COMMAND} import testdata/config2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123' "$output") = 'same' ]]
}

####  EXPORT

@test "exporting with '--kubeconfig' yields original config" {
  run ${COMMAND} export context1 --kubeconfig testdata/config123
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config1' "$output") = 'same' ]]
}

@test "exporting without '--kubeconfig' yields original config" {
  run ${COMMAND} export context2 testdata/config123
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config2' "$output") = 'same' ]]
}

@test "exporting with KUBECONFIG yields original config" {
  use_config config123
  run ${COMMAND} export context3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config3' "$output") = 'same' ]]
}

@test "exporting with multiple from multiple kubeconfigs - I" {
  run ${COMMAND} export context2,context3 --kubeconfig testdata/config12,testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config23' "$output") = 'same' ]]
}

@test "exporting with multiple from multiple kubeconfigs - II" {
  run ${COMMAND} export context1,context2 --kubeconfig testdata/config1,testdata/config23
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12' "$output") = 'same' ]]
}

@test "export with too many arguments - I" {
  run ${COMMAND} export foo bar baz
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "error: too many arguments"* ]]
}

@test "export with too many arguments - II" {
  run ${COMMAND} export foo --kubeconfig bar baz
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "error: too many arguments"* ]]
}

####  ERRORS

@test "no kubectl detected" {
  OLDPATH="$PATH"
  PATH=/bin
  run ${COMMAND}
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "kubectl is not installed" ]]
  PATH="$OLDPATH"
}

@test "unknown subcommand" {
  run ${COMMAND} foobar
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - export" {
  run ${COMMAND} export -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - import" {
  run ${COMMAND} import -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - merge" {
  run ${COMMAND} merge -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - I" {
  run ${COMMAND} -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - II" {
  run ${COMMAND} --unknown
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"--unknown\""* ]]
}
