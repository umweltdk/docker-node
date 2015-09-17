#!/usr/bin/env bats

load test_helper
fixtures start

teardown() {
  docker rm -fv $BATS_TEST_NAME
  #docker rmi $BATS_TEST_NAME
}

@test "missing start script returns error" {
  docker build --rm -t $BATS_TEST_NAME $FIXTURE_ROOT/no-start-script

  run docker run --name $BATS_TEST_NAME $BATS_TEST_NAME
  echo -e "$output"
  [ "$status" -eq 1 ]
}

@test "failing start script returns error" {
  docker build --rm -t $BATS_TEST_NAME $FIXTURE_ROOT/failing-start-script

  run docker run --name $BATS_TEST_NAME $BATS_TEST_NAME
  echo -e "$output"
  [ "$status" -eq 1 ]
}

@test "running server returns ok" {
  docker build --rm -t $BATS_TEST_NAME $FIXTURE_ROOT/ok-start-script
  
  docker run --name $BATS_TEST_NAME $BATS_TEST_NAME &

  local retry=0;
  while [ "$retry" -lt 5 ]; do
    run docker run --rm --link $BATS_TEST_NAME:target buildpack-deps:curl curl --silent -f http://target:8080/check
    echo -e "$output"
    if [ "$status" -eq 0 ]; then
      break
    fi
    sleep 1
    retry=$(($retry + 1))
  done
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}