# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit multibuild postgres
EXPORT_FUNCTIONS pkg_setup src_prepare src_compile src_install src_test


# @ECLASS: postgres-multi
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass to build PostgreSQL-related packages against multiple slots
# @DESCRIPTION:
# postgres-multi enables ebuilds, particularly PostgreSQL extensions, to
# build against any and all compatible PostgreSQL slots that are also
# enabled by the user. Additionally makes a developer's life easier with
# exported default functions to do the right thing.


case ${EAPI:-0} in
  0|1|2|3|4) die "postgres-multi.eclass requires EAPI 5 or higher" ;;
  *) ;;
esac


# @ECLASS-VARIABLE: POSTGRES_COMPAT
# @REQUIRED
# @DESCRIPTION:
# A Bash array containing a list of compatible PostgreSQL slots as
# defined by the developer. Must be declared before inheriting this eclass.
if ! declare -p POSTGRES_COMPAT &>/dev/null; then
	die 'Required variable POSTGRES_COMPAT not declared.'
fi

# @ECLASS-VARIABLE: _POSTGRES_UNION_SLOTS
# @INTERNAL
# @DESCRIPTION:
# A Bash array containing the union set of user-enabled slots that are
# also in POSTGRES_COMPAT.
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
# PostgreSQL slot in the union set of the developer defined
# POSTGRES_COMPAT and user-enabled slots. The PG_CONFIG environment
# variable is updated on each iteration to point to the matching
# pg_config command for the current slot. Any appearance of @PG_SLOT@ in
# the command or arguments will be substituted with the slot (e.g., 9.5)
# of the current iteration.
postgres-multi_foreach() {
	local MULTIBUILD_VARIANTS=("${_POSTGRES_UNION_SLOTS[@]}")

	multibuild_foreach_variant \
		_postgres-multi_multibuild_wrapper run_in_build_dir ${@}
}

# @FUNCTION: postgres-multi_forbest
# @USAGE: postgres-multi_forbest <command> <arg> [<arg> ...]
# @DESCRIPTION:
# Run the given command in the package's source directory for the best,
# compatible PostgreSQL slot. The PG_CONFIG environment variable is set
# to the matching pg_config command. Any appearance of @PG_SLOT@ in the
# command or arguments will be substituted with the matching slot (e.g., 9.5).
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
# Initialize internal environment variable(s). This is required if
# pkg_setup() is declared in the ebuild.
postgres-multi_pkg_setup() {
	local user_slot

	for user_slot in "${POSTGRES_COMPAT[@]}"; do
		use "postgres_${user_slot/\./_}" && \
			_POSTGRES_UNION_SLOTS+=( "${user_slot}" )
	done

	if [[ "${#_POSTGRES_UNION_SLOTS[@]}" -eq "0" ]]; then
		die "One of the postgres_SL_OT use flags must be enabled"
	fi

	elog "Multibuild variants: ${_POSTGRES_UNION_SLOTS[@]}"
}

postgres-multi_src_prepare() {
	if [[ "${#_POSTGRES_UNION_SLOTS[@]}" -eq "0" ]]; then
		eerror "Internal array _POSTGRES_UNION_SLOTS is empty."
		die "Did you forget to call postgres-multi_pkg_setup?"
	fi

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
