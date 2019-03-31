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

@test "no kubectl detected" {
  OLDPATH="$PATH"
  PATH=/bin
  run ${COMMAND}
  echo "$output"
  [ "$status" -eq 1 ]
  [[ "$output" = "kubectl is not installed" ]]
  PATH="$OLDPATH"
}

@test "--help should not fail" {
  run ${COMMAND} --help
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "-h should not fail" {
  run ${COMMAND} -h
  echo "$output"
  [ "$status" -eq 0 ]
}

@test "combine three configs" {
  run ${COMMAND} testdata/config-{flat,non-flat,passwd}
  echo "$output"
  [ "$status" -eq 0 ]
  [[ $(check_fixture 'testdata/config-multiple' "$output") = 'same' ]]
}

@test "combine, not enough arguments" {
  run ${COMMAND} testdata/config-flat
  echo "$output"
  [ "$status" -eq 1 ]
  [[ "$output" = "error: not enough arguments"* ]]
}

@test "extracting yields original config - I" {
  run ${COMMAND} -e config-flat testdata/config-multiple
  echo "$output"
  [ "$status" -eq 0 ]
  [[ $(check_fixture 'testdata/config-flat' "$output") = 'same' ]]
}

@test "extracting yields original config - II" {
  run ${COMMAND} --extract config-non-flat testdata/config-multiple
  echo "$output"
  [ "$status" -eq 0 ]
  [[ $(check_fixture 'testdata/config-non-flat' "$output") = 'same' ]]
}

@test "extracting yields original config - III" {
  use_config config-multiple
  run ${COMMAND} --extract config-passwd
  echo "$output"
  [ "$status" -eq 0 ]
  [[ $(check_fixture 'testdata/config-passwd' "$output") = 'same' ]]
}

@test "extract with too many arguments" {
  run ${COMMAND} --extract foo bar baz
  echo "$output"
  [ "$status" -eq 1 ]
  [[ "$output" = "error: too many arguments"* ]]
}

@test "unknown flag - I" {
  run ${COMMAND} -u
  echo "$output"
  [ "$status" -eq 1 ]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - II" {
  run ${COMMAND} --unknown
  echo "$output"
  [ "$status" -eq 1 ]
  [[ "$output" = *"error: unrecognized flag \"--unknown\""* ]]
}
