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
# build and install for one or more PostgreSQL slots as specified by
# POSTGRES_TARGETS use flags.


case ${EAPI:-0} in
	5|6) ;;
	*) die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}" ;;
esac


# @ECLASS-VARIABLE: POSTGRES_COMPAT
# @REQUIRED
# @DESCRIPTION:
# A Bash array containing a list of compatible PostgreSQL slots as
# defined by the developer. Must be declared before inheriting this
# eclass. Example: POSTGRES_COMPAT=( 9.4 9.{5,6} )
if ! declare -p POSTGRES_COMPAT &>/dev/null; then
	die 'Required variable POSTGRES_COMPAT not declared.'
fi

# @ECLASS-VARIABLE: _POSTGRES_INTERSECT_SLOTS
# @INTERNAL
# @DESCRIPTION:
# A Bash array containing the intersect of POSTGRES_TARGETS and
# POSTGRES_COMPAT.
export _POSTGRES_INTERSECT_SLOTS=( )

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
# Run the given command in the package's build directory for each
# PostgreSQL slot in the intersect of POSTGRES_TARGETS and
# POSTGRES_COMPAT and user-enabled slots. The PG_CONFIG environment
# variable is updated on each iteration to point to the matching
# pg_config command for the current slot. Any appearance of @PG_SLOT@ in
# the command or arguments will be substituted with the slot (e.g., 9.5)
# of the current iteration.
postgres-multi_foreach() {
	local MULTIBUILD_VARIANTS=("${_POSTGRES_INTERSECT_SLOTS[@]}")

	multibuild_foreach_variant \
		_postgres-multi_multibuild_wrapper run_in_build_dir ${@}
}

# @FUNCTION: postgres-multi_forbest
# @USAGE: postgres-multi_forbest <command> <arg> [<arg> ...]
# @DESCRIPTION:
# Run the given command in the package's build directory for the highest
# slot in the intersect of POSTGRES_COMPAT and POSTGRES_TARGETS. The
# PG_CONFIG environment variable is set to the matching pg_config
# command. Any appearance of @PG_SLOT@ in the command or arguments will
# be substituted with the matching slot (e.g., 9.5).
postgres-multi_forbest() {
	# POSTGRES_COMPAT is reverse sorted once in postgres.eclass so
	# element 0 has the highest slot version.
	local MULTIBUILD_VARIANTS=("${_POSTGRES_INTERSECT_SLOTS[0]}")

	multibuild_foreach_variant \
		_postgres-multi_multibuild_wrapper run_in_build_dir ${@}
}

# @FUNCTION: postgres-multi_pkg_setup
# @REQUIRED
# @USAGE: postgres-multi_pkg_setup
# @DESCRIPTION:
# Initialize internal environment variable(s). This is required if
# pkg_setup() is declared in the ebuild.
postgres-multi_pkg_setup() {
	local user_slot

	for user_slot in "${POSTGRES_COMPAT[@]}"; do
		use "postgres_targets_postgres${user_slot/\./_}" && \
			_POSTGRES_INTERSECT_SLOTS+=( "${user_slot}" )
	done

	if [[ "${#_POSTGRES_INTERSECT_SLOTS[@]}" -eq "0" ]]; then
		die "One of the postgres_targets_postgresSL_OT use flags must be enabled"
	fi

	einfo "Multibuild variants: ${_POSTGRES_INTERSECT_SLOTS[@]}"
}

# @FUNCTION: postgres-multi_src_prepare
# @REQUIRED
# @USAGE: postgres-multi_src_prepare
# @DESCRIPTION:
# Calls eapply_user then copies ${S} into a build directory for each
# intersect of POSTGRES_TARGETS and POSTGRES_COMPAT.
postgres-multi_src_prepare() {
	if [[ "${#_POSTGRES_INTERSECT_SLOTS[@]}" -eq "0" ]]; then
		eerror "Internal array _POSTGRES_INTERSECT_SLOTS is empty."
		die "Did you forget to call postgres-multi_pkg_setup?"
	fi

	case ${EAPI:-0} in
		0|1|2|3|4|5) epatch_user ;;
		6) eapply_user ;;
	esac

	local MULTIBUILD_VARIANT
	local MULTIBUILD_VARIANTS=("${_POSTGRES_INTERSECT_SLOTS[@]}")
	multibuild_copy_sources
}

# @FUNCTION: postgres-multi_src_compile
# @USAGE: postgres-multi_src_compile
# @DESCRIPTION:
# Runs `emake' in each build directory

postgres-multi_src_compile() {
	postgres-multi_foreach emake
}

# @FUNCTION: postgres-multi_src_install
# @USAGE: postgres-multi_src_install
# @DESCRIPTION:
# Runs `emake install DESTDIR="${D}"' in each build directory.
postgres-multi_src_install() {
	postgres-multi_foreach emake install DESTDIR="${D}"
}

# @FUNCTION: postgres-multi_src_test
# @USAGE: postgres-multi_src_test
# @DESCRIPTION:
# Runs `emake installcheck' in each build directory.
postgres-multi_src_test() {
	postgres-multi_foreach emake installcheck
}
