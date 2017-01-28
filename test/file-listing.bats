#!/usr/bin/env bats

load test_helper
fixtures
create_test_file_structure

@test "aliases are recognizable" {
  run alias lf
  [ $status -eq 0 ]

  run alias lfi
  [ $status -eq 0 ]

  run alias lfs
  [ $status -eq 0 ]
}

@test "confirm file structure for testing" {
  [ -d "${FIXTURE_ROOT}/${TEST_FS}" ]
}

@test "_join works as expected" {
  run _join '*' hello world
  [ $status -eq 0 ]
  [ "$output" = '*hello*world' ]

  #run _join '.*' hello world
  #[ $status -eq 0 ]
  #[ "$output" = '.*hello.*world' ]
}

@test "list all files" {
  run _lf path --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = ".config" ]
  [ "${lines[10]}" = "files/folder 1/bar.txt" ]

  run _lf path . --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = ".config" ]
  [ "${lines[10]}" = "files/folder 1/bar.txt" ]

  run _lf path ./ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = ".config" ]
  [ "${lines[10]}" = "files/folder 1/bar.txt" ]

  run _lf path + --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = "$PWD/.config" ]
  [ "${lines[10]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "list files with a file extention" {
  run _lf path .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 5 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[3]}" = "files/folder 0/foo.txt" ]
  [ "${lines[4]}" = "files/folder 1/bar.txt" ]
}

@test "list files with file pattern " {
  run _lf path empty*
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]

  run _lf path + empty*
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "$PWD/files/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
}

@test "list files with an intermediate folder and file extention" {
  run _lf path database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]

  run _lf path + database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "$PWD/database/civilizer.h2.db" ]
}

@test "list files with an intermediate folder and file extention (ignore cases)" {
  run _lf ipath database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]
  [ "${lines[1]}" = "database/civilizer.TRACE.DB" ]

  run _lf ipath + database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "$PWD/database/civilizer.h2.db" ]
  [ "${lines[1]}" = "$PWD/database/civilizer.TRACE.DB" ]
}

@test "list files with intermediate folders" {
  run _lf path files folder --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 4 ]
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]
  [ "${lines[3]}" = "files/folder 1/bar.txt" ]

  run _lf path + files folder --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 4 ]
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
  [ "${lines[3]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "list files with intermediate folders and file extention" {
  run _lf path files folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]

  run _lf path + files folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
}

@test "list all dot-prefixed files" {
  run _lf path . /. --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ ${lines[0]} = ".config" ]
  [ ${lines[1]} = ".hidden/baz.lst" ]
  [ ${lines[2]} = ".hidden/log/error.log" ]

  run _lf path . .hidd --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ ${lines[0]} = ".hidden/baz.lst" ]
  [ ${lines[1]} = ".hidden/log/error.log" ]

  run _lf path + /. --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ ${lines[0]} = "$PWD/.config" ]
  [ ${lines[1]} = "$PWD/.hidden/baz.lst" ]
  [ ${lines[2]} = "$PWD/.hidden/log/error.log" ]

  run _lf path + .hidd --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ ${lines[0]} = "$PWD/.hidden/baz.lst" ]
  [ ${lines[1]} = "$PWD/.hidden/log/error.log" ]
}

