#set -x
fixtures() {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "$FIXTURE_ROOT")"
  FIXTURE_TMP_ROOT="$BATS_TEST_DIRNAME/tmp/$NODE_VERSION/$1"
  mkdir -p "$FIXTURE_TMP_ROOT"
}

fixture() {
  rm -rf "$FIXTURE_TMP_ROOT/$1/"
  cp -R "$FIXTURE_ROOT/$1/" "$FIXTURE_TMP_ROOT/$1/"
  if [ "${NODE_VERSION}" == "latest" ]; then
    sed -E -i "s/^(FROM .+:).+onbuild(-bower)?/\1onbuild\2/;" "$FIXTURE_TMP_ROOT/$1/Dockerfile"
  else
    sed -E -i "s/^(FROM .+:).+-onbuild(-bower)?/\1${NODE_VERSION}-onbuild\2/;" "$FIXTURE_TMP_ROOT/$1/Dockerfile"
  fi
  echo "$FIXTURE_TMP_ROOT/$1"
}