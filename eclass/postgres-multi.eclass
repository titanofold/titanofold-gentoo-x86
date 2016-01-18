# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit multibuild postgres
EXPORT_FUNCTIONS pkg_setup src_prepare src_compile src_install src_test


# @ECLASS: postgres-multi
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass for PostgreSQL-related packages with default functions
# @DESCRIPTION:
# postgres-multi enables ebuilds, particularly PostgreSQL extensions, to
# build against any and all compatible, installed PostgreSQL
# slots. Additionally exports default functions.


case ${EAPI:-0} in
  0|1|2|3|4) die "postgres-multi.eclass requires EAPI 5 or higher" ;;
  *) ;;
esac


# @ECLASS-VARIABLE: POSTGRES_COMPAT
# @REQUIRED
# @DESCRIPTION:
# A Bash array containing a list of compatible PostgreSQL slots as
# defined by the developer.
if ! declare -p POSTGRES_COMPAT &>/dev/null; then
	die 'Required variable POSTGRES_COMPAT not declared.'
fi

# @ECLASS-VARIABLE: _POSTGRES_UNION_SLOTS
# @INTERNAL
# @DESCRIPTION:
# A Bash array containing the union set of available slots installed on the
# system that are also in POSTGRES_COMPAT.
export _POSTGRES_UNION_SLOTS=( )

# @FUNCTION _postgres-multi_multibuild_wrapper
# @INTERNAL
# @USAGE: _postgres-multi_multibuild_wrapper <command> [<arg> ...]
# @DESCRIPTION:
# For the given variant, set the values of the PG_SLOT and PG_CONFIG
# environment variables accordingly and replace any appearance of
# @PG_SLOT@ in the command and arguments with value of ${PG_SLOT}.
_postgres-multi_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	export PG_SLOT=${MULTIBUILD_VARIANT}
	export PG_CONFIG=$(which pg_config${MULTIBUILD_VARIANT//./})
	$(echo "${@}" | sed "s/@PG_SLOT@/${PG_SLOT}/g")
}

# @FUNCTION: postgres-multi_foreach
# @USAGE: postgres-multi_foreach <command> <arg> [<arg> ...]
# @DESCRIPTION:
# Run the given command in the package's source directory for each
# installed PostgreSQL slot. Any appearance of @PG_SLOT@ in the command
# or arguments will be substituted with the slot of the current
# iteration.
postgres-multi_foreach() {
	local MULTIBUILD_VARIANTS=("${_POSTGRES_UNION_SLOTS[@]}")

	multibuild_foreach_variant \
		_postgres-multi_multibuild_wrapper run_in_build_dir ${@}
}

# @FUNCTION: postgres-multi_forbest
# @USAGE: postgres-multi_forbest <command> <arg> [<arg> ...]
# @DESCRIPTION:
# Run the given command in the package's source directory for the best
# installed, compatible PostgreSQL slot. Any appearance of @PG_SLOT@ in
# the command or arguments will be substituted with the matching slot.
postgres-multi_forbest() {
	# POSTGRES_COMPAT is reverse sorted once in postgres.eclass so
	# element 0 has the highest slot version.
	local MULTIBUILD_VARIANTS=("${_POSTGRES_UNION_SLOTS[0]}")

	multibuild_foreach_variant \
		_postgres-multi_multibuild_wrapper run_in_build_dir ${@}
}

# @FUNCTION: postgres-multi_pkg_setup
# @USAGE: postgres-multi_pkg_setup
# @DESCRIPTION:
# Initialize internal environment variable(s).
postgres-multi_pkg_setup() {
	local user_slot

	for user_slot in "${POSTGRES_COMPAT[@]}"; do
		use "postgres_${user_slot/\./_}" && \
			_POSTGRES_UNION_SLOTS+=( "${user_slot}" )
	done

	elog "Multibuild variants: ${_POSTGRES_UNION_SLOTS[@]}"
}

postgres-multi_src_prepare() {
	local MULTIBUILD_VARIANT
	local MULTIBUILD_VARIANTS=("${_POSTGRES_UNION_SLOTS[@]}")
	multibuild_copy_sources
}

postgres-multi_src_compile() {
	postgres-multi_foreach emake
}

postgres-multi_src_install() {
	postgres-multi_foreach emake install DESTDIR="${D}"
}

postgres-multi_src_test() {
	postgres-multi_foreach emake installcheck
}
