#!/usr/bin/env bash

matches_version () {
    egrep -q '^v[0-9]+\.[0-9]+$'
}

fail () {
    test 0 == "$1" && return 0
    echo "$2" >&2
    exit $1
}

copy_version_directories () {
    echo "$1" | matches_version || fail $? "Not a version string: $1"
    echo "$2" | matches_version || fail $? "Not a version string: $2"

    find ./ -type d -name "$1" | while read vpath; do
        echo "Cloning $vpath to $(dirname $vpath)/${2}" >&2
        cp -nrv "$vpath/"  "$(dirname $vpath)/${2}"
    done

}

copy_version_to_defaults () {
    echo "$1" | matches_version || fail $? "Not a version string: $1"
    
    find ./ -type d -name "$1" | while read vpath; do
        find "$vpath" -maxdepth 1 -type f -print0 | xargs -0 -I % cp -v % "$(dirname $vpath)"
    done
}

copy_defaults_to_version () {
    echo "$1" | matches_version || fail $? "Not a version string: $1"

    find ./ansible/roles -type d -name 'templates' | while read tpath; do
        mkdir -p "$tpath/$1"
        find "$tpath" -maxdepth 1 -type f | xargs -I % cp -vn % "$tpath/$1/"
    done
}

case $1 in 
    copy) copy_version_directories "$2" "$3" ;;
    copy_default) copy_defaults_to_version "$2" ;;
esac

