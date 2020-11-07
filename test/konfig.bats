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

COMMAND="$BATS_TEST_DIRNAME/../konfig"

load common

####  HELP

@test "help should not fail" {
  run ${COMMAND} help
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "konfig helps to merge"* ]]
}

@test "--help should not fail" {
  run ${COMMAND} --help
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "konfig helps to merge"* ]]
}

@test "-h should not fail" {
  run ${COMMAND} -h
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "konfig helps to merge"* ]]
}

@test "no arguments given" {
  run ${COMMAND}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "konfig helps to merge"* ]]
}

####  MERGE

@test "merge --preserve-structure: three configs" {
  run ${COMMAND} merge --preserve-structure testdata/config{1,-2,3}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123' "$output") = 'same' ]]
}

@test "vanilla merge: three configs" {
  run ${COMMAND} merge testdata/config{1,-2,3}
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

@test "import single config and print to stdout" {
  use_config config1
  run ${COMMAND} import testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12-flat' "$output") = 'same' ]]
}

@test "import multiple configs and print to stdout" {
  use_config config1
  run ${COMMAND} import testdata/config-2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123-flat' "$output") = 'same' ]]
}

@test "import single config" {
  use_config config1
  run ${COMMAND} import --save testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config12-flat') = 'same' ]]
}

@test "import multiple configs" {
  use_config config1
  run ${COMMAND} import -s testdata/config-2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config123-flat') = 'same' ]]
}

@test "import single config and preserve structure" {
  use_config config1
  run ${COMMAND} import --preserve-structure --save testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config12') = 'same' ]]
}

@test "import multiple configs and preserve structure" {
  use_config config1
  run ${COMMAND} import -p -s testdata/config-2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config123') = 'same' ]]
}

@test "failed read of imported config should preserve .kube/config" {
  use_config config1
  chmod u-r testdata/config-2
  run ${COMMAND} import -s /does/not/exist testdata/config-2
  chmod u+r testdata/config-2
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

####  EXPORT

@test "exporting with '--kubeconfig' yields original config - I" {
  run ${COMMAND} export context1 --kubeconfig testdata/config123
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config1' "$output") = 'same' ]]
}

@test "exporting with '--kubeconfig' yields original config - II" {
  run ${COMMAND} export -k testdata/config123 context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config2-flat' "$output") = 'same' ]]
}

@test "exporting with KUBECONFIG yields original config" {
  use_config config123
  run ${COMMAND} export context3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config3' "$output") = 'same' ]]
}

@test "exporting with multiple from multiple kubeconfigs - I" {
  run ${COMMAND} split context2 context3 -k testdata/config1,testdata/config3 --kubeconfig testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config23-flat' "$output") = 'same' ]]
}

@test "exporting with multiple from multiple kubeconfigs - II" {
  run ${COMMAND} split -k testdata/config1 context1 --kubeconfig testdata/config23 context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12-flat' "$output") = 'same' ]]
}

@test "exporting without any context - I" {
  run ${COMMAND} export -k testdata/config1 -k testdata/config23
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: contexts to export are missing"* ]]
}

@test "exporting without any context - I" {
  run ${COMMAND} export
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: contexts to export are missing"* ]]
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
  [[ "$output" = *"error: unknown command \"foobar\""* ]]
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
