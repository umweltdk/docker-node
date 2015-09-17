#!/bin/bash
[ -n "$DEBUG" ] && set -o xtrace
set -o errexit

build_root=/usr/src/app

echo_title() {
  echo "$@" 1>&2
}

make_slug() {
  local build_root="$1"
  local slug_file="$2"
  if [[ -f "$build_root/.slugignore" ]]; then
    tar -z -X "$build_root/.slugignore" -C $build_root -cf $slug_file . | cat
  else
    tar -z -C $build_root -cf $slug_file . | cat
  fi
}

case "$1" in
  build)
    if jq -e .scripts.build package.json > /dev/null; then
      npm run build
    fi
    ;;

  test)
    exec npm test
    ;;

  start)
    exec npm start
    ;;

  slug)
    if [[ "$2" == "-" ]]; then
        slug_file="$2"
    else
        slug_file=/tmp/slug.tgz
        if [[ "$2" ]]; then
            put_url="$2"
        fi
    fi
    
    make_slug "$build_root" "$slug_file"

    if [[ "$slug_file" != "-" ]]; then
      slug_size=$(du -Sh "$slug_file" | cut -f1)
      echo_title "Compiled slug size is $slug_size"

      if [[ "$put_url" ]]; then
        curl -0 -s -o /dev/null -X PUT -T "$slug_file" "$put_url"
      fi
    fi
    ;;

  eb-export)
    eb_export_path=/tmp/eb-export

    mkdir $eb_export_path
    make_slug "$build_root" "$eb_export_path/slug.tgz"

    if [[ -f "$build_root/Dockerrun.aws.json" ]]; then
      cp $build_root/Dockerrun.aws.json $eb_export_path
    fi

    if [[ -f "$build_root/Dockerfile.export" ]]; then
      cp $build_root/Dockerfile.export $eb_export_path/Dockerfile
    else
      echo "FROM griff/node-builder-export:0.12" > $eb_export_path/Dockerfile
    fi

    cd $eb_export_path
    zip -r - .
    ;;

  *)
    exec "$@"
    ;;
esac
