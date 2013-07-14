# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python-single-r1.eclass,v 1.18 2013/05/21 01:31:02 floppym Exp $

inherit multibuild postgres
EXPORT_FUNCTIONS src_compile src_install src_test foreach_impl


# @ECLASS: postgres-multi
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass for PostgreSQL-related packages
# @DESCRIPTION:
# This eclass provides default functions to build a package for all
# compatible PostgreSQL slots.


# @ECLASS-VARIABLE: POSTGRES_COMPAT
# @REQUIRED
# @DESCRIPTION:
# This variable contains a list of compatible postgres slots.
if ! declare -p POSTGRES_COMPAT &>/dev/null; then
	die 'POSTGRES_COMPAT not declared.'
fi

# @ECLASS-VARIABLE: _POSTGRES_ALL_SLOTS
# @INTERNAL
# @DESCRIPTION:
# This variable contains a list of all available slots
_POSTGRES_ALL_SLOTS=$(eselect --brief postgresql list)

_postgres-multi_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	local PG_SLOT=${MULTIBUILD_VARIANT}
	export PG_CONFIG="pg_config${MULTIBUILD_VARIANT//./}"
	$(echo "${@}" | sed "s/@PG_SLOT@/${PG_SLOT}/g")
}

postgres-multi_foreach_impl() {
	debug-print-function ${FUNCNAME} "${@}"
	local MULTIBUILD_VARIANTS
	postgres-multi_get_impls
	multibuild_foreach_variant _postgres-multi_multibuild_wrapper "${@}"
}

postgres-multi_get_impls() {
	debug-print-function ${FUNCNAME} "${@}"
	MULTIBUILD_VARIANTS=( )
	local user_slot
	for user_slot in "${POSTGRES_COMPAT[@]}"; do
		has "${user_slot}" ${_POSTGRES_ALL_SLOTS} && \
			MULTIBUILD_VARIANTS+=( "${user_slot}" )
	done
	if [[ -z ${MULTIBUILD_VARIANTS} ]]; then
		die "You don't have any suitable postgresql slots installed. "\
			"You should install one of the following postgresql slots: "\
			"${POSTGRES_COMPAT}"
	fi;
	elog "Multibuild variants: ${MULTIBUILD_VARIANTS[@]}"
}

postgres-multi_src_prepare() {
	local MULTIBUILD_VARIANT
	postgres-multi_get_impls
	multibuild_copy_sources
}

postgres-multi_src_compile() {
	postgres-multi_foreach_impl run_in_build_dir emake
}

postgres-multi_src_install() {
	postgres-multi_foreach_impl run_in_build_dir emake install DESTDIR="${D}"
}

postgres-multi_src_test() {
	postgres-multi_foreach_impl run_in_build_dir emake installcheck
}
