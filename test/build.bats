#!/usr/bin/env bats

load test_helper
fixtures build

@test "fails to build with missing node dependency" {
  ! docker build --rm $FIXTURE_ROOT/missing-dependency
}

@test "fails to build with missing package.json" {
  ! docker build --rm $FIXTURE_ROOT/missing-package-json
}

@test "fails to build with missing bower dependency" {
  ! docker build --rm $FIXTURE_ROOT/missing-bower-dependency
}

@test "fails to build with missing bower.json" {
  ! docker build --rm $FIXTURE_ROOT/missing-bower-json
}

@test "fails to build with failing build script" {
  ! docker build --rm $FIXTURE_ROOT/failing-build-script
}

@test "succeeds in building with missing build script" {
  docker build --rm $FIXTURE_ROOT/missing-build-script
}

@test "succeeds in building when touching file" {
  docker build --rm $FIXTURE_ROOT/touch-file
}

@test "fails to build bower version with failing build script" {
  ! docker build --rm $FIXTURE_ROOT/failing-bower-build-script
}

@test "succeeds in building bower version with missing build script" {
  docker build --rm $FIXTURE_ROOT/missing-bower-build-script
}
