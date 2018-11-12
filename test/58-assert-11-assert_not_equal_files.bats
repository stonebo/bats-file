#!/usr/bin/env bats

load 'test_helper'
fixtures 'exist'

# Correctness
@test 'assert_files_not_equal() <file1> <file2>: returns 0 if <file1> and <file2> are not the same' {
  local -r file1="${TEST_FIXTURE_ROOT}/dir/file_with_text"
  local -r file2="${TEST_FIXTURE_ROOT}/dir/file"
  run assert_files_not_equal "$file1" "$file2"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}


@test 'assert_files_not_equal() <file1> <file2>: returns 1 if <file1> and <file2> are the same' {
  local -r file1="${TEST_FIXTURE_ROOT}/dir/same_file_with_text"
  local -r file2="${TEST_FIXTURE_ROOT}/dir/file_with_text"
  run assert_files_not_equal "$file1" "$file2"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- files are the same --' ]
  [ "${lines[1]}" == "path : $file1" ]
  [ "${lines[2]}" == "path : $file2" ]
  [ "${lines[3]}" == "--" ]
}

# Transforming path
@test 'assert_files_not_equal() <file1> <file2>: used <file2> as a directory' {
  local -r file2="${TEST_FIXTURE_ROOT}/dir/same_file_with_text"
  local -r file1="${TEST_FIXTURE_ROOT}/dir"
  run assert_files_not_equal "$file1" "$file2"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "${lines[0]}" == "cmp: ${TEST_FIXTURE_ROOT}/dir: Is a directory" ]
}

@test 'assert_files_not_equal() <file>: replace prefix of displayed path' {
  local -r file2="${TEST_FIXTURE_ROOT}/dir/same_file_with_text"
  local -r file1="${TEST_FIXTURE_ROOT}/dir/file_with_text"
  local -r BATSLIB_FILE_PATH_REM="#${TEST_FIXTURE_ROOT}"
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_files_not_equal "$file1" "$file2"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- files are the same --' ]
  [ "${lines[1]}" == "path : ../dir/file_with_text" ]
  [ "${lines[2]}" == "path : ../dir/same_file_with_text" ]
  [ "${lines[3]}" == "--" ]
}

@test 'assert_files_not_equal() <file>: replace suffix of displayed path' {
  local -r file2="${TEST_FIXTURE_ROOT}/dir/same_file_with_text"
  local -r file1="${TEST_FIXTURE_ROOT}/dir/file_with_text"
  local -r BATSLIB_FILE_PATH_REM='%same_file_with_text'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_files_not_equal "$file1" "$file2"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- files are the same --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/dir/file_with_text" ]
  [ "${lines[2]}" == "path : ${TEST_FIXTURE_ROOT}/dir/.." ]
  [ "${lines[3]}" == "--" ]
}

@test 'assert_files_not_equal() <file>: replace infix of displayed path' {
  local -r file2="${TEST_FIXTURE_ROOT}/dir/same_file_with_text"
  local -r file1="${TEST_FIXTURE_ROOT}/dir/file_with_text"
  local -r BATSLIB_FILE_PATH_REM='dir'
  local -r BATSLIB_FILE_PATH_ADD='..'
  run assert_files_not_equal "$file1" "$file2"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- files are the same --' ]
  [ "${lines[1]}" == "path : ${TEST_FIXTURE_ROOT}/../file_with_text" ]
  [ "${lines[2]}" == "path : ${TEST_FIXTURE_ROOT}/../same_file_with_text" ]
  [ "${lines[3]}" == "--" ]
}
