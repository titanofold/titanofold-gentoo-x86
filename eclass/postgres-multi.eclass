# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit multibuild postgres
EXPORT_FUNCTIONS src_compile src_install src_test

# @ECLASS: postgres-multi
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass for PostgreSQL-related packages
# @DESCRIPTION:
# This eclass provides default functions to build a package for all
# compatible PostgreSQL slots as defined in POSTGRES_COMPAT.

# @FUNCTION _postgres-multi_multibuild_wrapper
# @USAGE: <command> [<args>]
# @DESCRIPTION:
# Intended for internal use only. Updates the environment with the
# respective PG_SLOT and PG_CONFIG for the currently selected multibuild
# variant, and replaces instances of @PG_SLOT@ in the given command with
# ${PG_SLOT}.
_postgres-multi_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	local PG_SLOT=${MULTIBUILD_VARIANT}
	export PG_CONFIG="pg_config${MULTIBUILD_VARIANT//./}"
	$(echo "${@}" | sed "s/@PG_SLOT@/${PG_SLOT}/g")
}

# @FUNCTION: postgres-multi_get_impls
# @DESCRIPTION:
# Set the MULTIBUILD_VARIANTS to the union set of POSTGRES_COMPAT and
# POSTGRES_ALL_SLOTS.
postgres-multi_get_impls() {
	debug-print-function ${FUNCNAME} "${@}"
	MULTIBUILD_VARIANTS=( )
	local user_slot
	for user_slot in "${POSTGRES_COMPAT[@]}"; do
		has "${user_slot}" ${_POSTGRES_ALL_SLOTS} && \
			MULTIBUILD_VARIANTS+=( "${user_slot}" )
	done
	if [[ -z ${MULTIBUILD_VARIANTS} ]]; then
		eerror "You don't have any suitable PostgreSQL slots installed. You must"
		eerror "install one of the following PostgreSQL slots:"
		eerror "    ${POSTGRES_COMPAT}"
		die
	fi

	[[ "${EBUILD_PHASE}" = "prepare" ]] \
		&& elog "Building for PostgreSQL slots: ${MULTIBUILD_VARIANTS[@]}"
}

# @FUNCTION: postgres-multi_foreach
# @USAGE: <command> [<args>...]
# @DESCRIPTION:
# Run the given command for each supported PostgreSQL slot. If you need
# a slot-specific path, @PG_SLOT@ will be replaced by the current slot.
postgres-multi_foreach_impl() {
	debug-print-function ${FUNCNAME} "${@}"
	local MULTIBUILD_VARIANTS
	postgres-multi_get_impls
	multibuild_foreach_variant _postgres-multi_multibuild_wrapper "${@}"
}

# @FUNCTION: postgres-multi_foreach
# @USAGE: <command> [<args>...]
# @DESCRIPTION:
# Run the given command in the package's source directory for each
# supported PostgreSQL slot. If you need a slot-specific path, @PG_SLOT@
# will be replaced by the current slot.
postgres-multi_foreach() {
	postgres-multi_foreach_impl run_in_build_dir \
		_postgres-multi_multibuild_wrapper "${@}"
}

postgres-multi_src_prepare() {
	local MULTIBUILD_VARIANT
	postgres-multi_get_impls
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
