#/bin/bash

set -e

cd

if [[ -e $PKG_HOME/.bootstrapped ]]; then
  exit 0
fi

mkdir -p `dirname "$PYPY_HOME"`
wget -O - "$PYPY_DOWNLOAD_URL/pypy-$PYPY_VERSION-linux_x86_64-portable.tar.bz2" |tar -xjf -
mv -n "pypy-$PYPY_VERSION-linux_x86_64-portable" "$PYPY_HOME"

"$PYPY_HOME/bin/pypy" --version

touch "$PKG_HOME/.bootstrapped"
