# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python-single-r1.eclass,v 1.18 2013/05/21 01:31:02 floppym Exp $

inherit multibuild
EXPORT_FUNCTIONS src_compile src_install src_test foreach_impl


# @ECLASS: postgres
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass for PostgreSQL-related packages
# @DESCRIPTION:
# This eclass provides common utility functions that many
# PostgreSQL-related packages perform, such as checking that the
# currently selected PostgreSQL slot is within a range, adding a user,
# and, eventually, installing against multiple slots.


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

_postgres_multibuild_wrapper() {
	debug-print-function ${FUNCNAME} "${@}"
	local PG_SLOT=${MULTIBUILD_VARIANT}
	export PG_CONFIG="pg_config${MULTIBUILD_VARIANT//./}"
	"${@}"
}

postgres_foreach_impl() {
	debug-print-function ${FUNCNAME} "${@}"
	local MULTIBUILD_VARIANTS
	postgres_get_impls
	multibuild_foreach_variant _postgres_multibuild_wrapper "${@}"
}

postgres_get_impls() {
	debug-print-function ${FUNCNAME} "${@}"
	MULTIBUILD_VARIANTS=( )
	for user_slot in "${POSTGRES_COMPAT[@]}"; do
		if has "${user_slot}" ${_POSTGRES_ALL_SLOTS}; then
			# Check that pg_config is successfully installed for this version.
			$(which pg_config${user_slot//./} &> /dev/null) && \
				MULTIBUILD_VARIANTS+=( "${user_slot}" ) 
		fi;
	done;
	if [[ -z ${MULTIBUILD_VARIANTS} ]]; then
		die "You don't have any suitable postgresql slots installed. "\
			"You should install one of the following postgresql slots: "\
			"${POSTGRES_COMPAT}"
	fi;
	elog "Multibuild variants: ${MULTIBUILD_VARIANTS[@]}"
}

postgres_src_prepare() {
	local MULTIBUILD_VARIANT
	postgres_get_impls
	multibuild_copy_sources
	postgres_for_each_impl run_in_build_dir mkdir './image/'
}

postgres_src_compile() {
	postgres_foreach_impl run_in_build_dir emake
}

postgres_src_install() {
	postgres_foreach_impl run_in_build_dir emake install DESTDIR="${D}"
}

postgres_src_test() {
	postgres_foreach_impl run_in_build_dir emake installcheck
}
