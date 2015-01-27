#!/bin/sh
#
# Build script that downloads a package with cower, and then builds it using
# makepkg.
#
# (C) mk
set -e
PATH="/usr/bin/core_perl:$PATH"

# Target package name.
package=$1

if [ -z "${package}" ]; then
  echo "Please specify a package to build."
  exit 1
fi

# Override undefined makepkg.conf variables.
[ -z "${PKGDEST}" ] && export PKGDEST=/packages
[ -z "${PACKAGER}" ] && export PACKAGER="Robuilder"

# Build it.
MAKEPKGOPTS="--skippgpcheck --syncdeps"
exec pacaur --noconfirm --noedit -Sa "${package}"
