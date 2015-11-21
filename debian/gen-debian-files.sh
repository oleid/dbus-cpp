#!/bin/sh

# Copyright (C) 2015 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authored by: Michi Henning <michi.henning@canonical.com>
#              Thomas Voß <thomas.voss@canonical.com>

#
# Script to generate debian files for dual landing in Vivid (gcc 4.9 ABI)
# and Wily and later (gcc 5 ABI).
#
# This script is called from debian/rules and generates:
#
# - control
# - libtrust-store${soversion}.install.${target_arch}
#
# For all but control, this is a straight substition and/or renaming exercise for each file.
# For control, if building on Wily or later, we also fix the "Replaces:" and "Conflicts:"
# entries, so we don't end up with two packages claiming ownership of the same places
# in the file system.
#
# Because the debian files for the different distributions are generated on the fly,
# this allows us to keep a single source tree for both distributions. See ../HACKING
# for more explanations.
#

set -e  # Fail if any command fails.

progname=$(basename $0)

[ $# -ne 1 ] && {
    echo "usage: $progname path-to-debian-dir" >&2
    exit 1
}
dir=$1
version_dir=$(mktemp -d)

# Dump version numbers into files and initialize vars from those files.

sh ${dir}/get-versions.sh ${dir} ${version_dir}

full_version=$(cat "${version_dir}"/libdbus-cpp.full-version)
major_minor=$(cat "${version_dir}"/libdbus-cpp.major-minor-version)
soversion=$(cat "${version_dir}"/libdbus-cpp.soversion)
vivid_soversion=$(cat "${version_dir}"/libdbus-cpp.vivid-soversion)

warning=$(mktemp -t gen-debian-files-msg.XXX)

trap "rm -fr $warning $version_dir" 0 INT TERM QUIT

warning_msg()
{
    cat >$warning <<EOF
# This file is autogenerated. DO NOT EDIT!
#
# Modifications should be made to $(basename "$1") instead.
# This file is regenerated automatically in the clean target.
#
EOF
}

# Generate debian/control from debian/control.in, substituting the soversion for both libs.
# For wily onwards, we also add an entry for the vivid versions to "Conflicts:" and "Replaces:".

infile="${dir}"/control.in
outfile="${dir}"/control
warning_msg $infile
cat $warning $infile \
    | sed -e "s/@DBUS_CPP_SOVERSION@/${soversion}/" > "$outfile"

[ "$distro" != "vivid" ] && {
    sed -i -e "/Replaces: libdbus-cpp4,/a\
\          libdbus-cpp${vivid_soversion}," \
        "$outfile"
}

# Generate the install files, naming them according to the soversion.

# Install file for binary package
infile="${dir}"/libdbus-cpp.install.in
outfile="${dir}"/libdbus-cpp${soversion}.install
warning_msg "$infile"
cat $warning "$infile" >"$outfile"

exit 0
