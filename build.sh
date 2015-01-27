#!/bin/sh
#
# Build script that downloads a package with cower, and then builds it using
# makepkg.
#
# (C) mk
set -e

# Target package name.
package=$1

if [ -z "${package}" ]; then
  echo "Please specify a package to build."
  exit 1
fi

# Override undefined makepkg.conf variables.
[ -z "${PKGDEST}" ] && export PKGDEST=/packages
[ -z "${PACKAGER}" ] && export PACKAGER="Robuilder"

# Download our package and then enter the directory.
cower -d "${package}" && cd "${package}"

# Build it.
exec makepkg --syncdeps --noconfirm --skippgpcheck
