#!/usr/bin/env bash

# Copyright 2015 Georgia Tech Research Corporation (GTRC). All rights reserved.

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.

set -o nounset -o errexit -o pipefail

root_dir=$(dirname "$0")/..
. "$root_dir"/share/wrtools-core/opt_help.bash
. "$root_dir"/share/wrtools-core/opt_verbose.bash
. "$root_dir"/share/wrtools-core/fail.bash
. "$root_dir"/share/wrtools-core/paranoia.bash
. "$root_dir"/share/wrtools-core/command-path.bash

share_dir=$root_dir/'M_SHARE_DIR_REL'

# all command-line processing is done here. This will pass stuff to
# the Java app, which has its own command-line processing.

#HELP:COMMAND_NAME: demonstrate XML Schema assembly and validation
#HELP:Usage: COMMAND_NAME [Options] $file1.xml $file2.xml ...
#HELP:Options:

#HELP:Options:
#HELP:  --help | -h: Print this help
#HELP:  --verbose | -v: Print additional diagnostics
#HELP:  --not-paranoid: Omit basic/foundational validations

#HELP:  --catalog=$file | -c $file: Use XML Catalog file to direct schema assembly
#HELP:      This opion can be used mulitple times. Order matters.
catalogs=()
opt_catalog () {
    (( $# == 1 )) || fail_assert "Need 1 argument (got $#)"
    catalogs+=( "$1" )
}

#HELP:  --log-level=(error|warn|debug|info|trace): set level of detail for logging
#HELP:        default is "error"
log_level=error
opt_log_level () {
    (( $# == 1 )) || fail_assert "Need 1 argument (got $#)"
    case $1 in
        error | warn | debug | info | trace ) log_level=$1;;
        * ) fail "unknown log level ($1)";;
    esac
}

#HELP:  --schema-location=$namespace-uri=$schema-location:
#HELP:      Use schema location to direct schema assembly
schema_locations=()
opt_schema_location () {
    (( $# == 2 )) || fail_assert "Need 2 arguments (got $#)"
    local array1=( $1 )
    (( ${#array1[@]} == 1 )) || fail "arguments to --schema-location can't have whitespace (arg 1 is \"$1\")"
    local array2=( $1 )
    (( ${#array2[@]} == 1 )) || fail "arguments to --schema-location can't have whitespace (arg 2 is \"$2\")"
    schema_locations+=( $1 $2 )
}

OPTIND=1
while getopts :c:hv-: option
do case "$option" in
       c ) opt_catalog "$OPTARG";;
       h ) opt_help;;
       v ) opt_verbose;;
       - ) case "$OPTARG" in
               catalog=* ) opt_catalog "${OPTARG#*=}";;
               help ) opt_help;;
               log-level=* ) opt_log_level "${OPTARG#*=}";;
               not-paranoid ) opt_not_paranoid;;
               schema-location=*=* )
                   sl_args=${OPTARG#*=}
                   opt_schema_location "${sl_args%%=*}" "${sl_args#*=}";;
               verbose ) opt_verbose;;
               
               catalog | log-level )
                   fail "Argument expected for long option \"$OPTARG\"";;
               help=* | verbose=* ) fail "No argument expected for long option \"${OPTARG%%=*}\"";;
               schema-location* )
                   fail "long option \"${OPTARG%%=*}\" takes two arguments (--${OPTARG%%=*}=\$namespace=\$location)";;
               * ) fail "Unknown long option \"$OPTARG\"";;
           esac;;
       '?' ) fail "Unknown short option \"$OPTARG\"";;
       : ) fail "Short option \"$OPTARG\" missing argument";;
       * ) fail "Bad state in getopts (OPTARG=\"$OPTARG\")";;
   esac
done
shift $((OPTIND-1))

vecho "share_dir=$share_dir"

classpath=$( find -L "${share_dir}" -type f -name '*.jar' -print0 | xargs -0 tokenize-strings --output-separator=: )
vecho "classpath=$classpath"

###############################################################################
# run

command=(java
         -Dprogram-name="$(get_command_path_short)"
         -Dorg.slf4j.simpleLogger.defaultLogLevel="$log_level"
         -Dorg.slf4j.simpleLogger.showLogName=false
         -Dorg.slf4j.simpleLogger.showThreadName=false
         -enableassertions
         -cp "$classpath"
         org.gtri.niem.xml_schema_validator.CLI)

for key in ${!catalogs[@]}
do command+=( --catalog "${catalogs[key]}" )
done

if (( ${#schema_locations[@]} > 0 ))
then command+=( --schema-location "$(tokenize-strings --output-separator=' ' "${schema_locations[@]}" )" )
fi

command+=("$@")

vrun "${command[@]}"

