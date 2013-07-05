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

# @FUNCTION: postgres_check_slot
# @DESCRIPTION:
# Determine if the currently selected slot is within the range specified
# by the user. If the check fails, it dies unless
# app-admin/eselect-postgresql is not installed. This is safe to call in
# pkg_pretend.
postgres_check_slot() {
       local PGSLOT="$(postgresql-config show) 2> /dev/null"

       # If app-admin/eselect-postgresql is not installed, or the slot
       # hasn't been set before pkg_pretend is called, skip the rest of
       # this function.
       if [[ -z ${PGSLOT} -o "${PGSLOT}" = "(none)" ]] ; then
               if [[ "$EBUILD_PHASE" = "pretend" ]] ; then
                       return 1
               else
                       if [[ "${PGSLOT}" = "(none)" ]] ; then
                               die "Please set a default slot with postgresql-config"
                       elif [[ -z ${PGSLOT} ]] ; then
                               die "This isn't supposed to happen."
                       fi
               fi
       fi

       if [[ -n $PG_SLOT_MIN && $PG_SLOT_MIN != -1 ]] ; then
               if [[ ${PGSLOT//.} < ${PG_SLOT_MIN//.} ]] ; then
                       eerror "You must build ${CATEGORY}/${PN} against PostgreSQL ${PG_SLOT_MIN} or higher."
                       eerror "Set an appropriate slot with postgresql-config."
                       die
               fi
       fi

       if [[ -n $PG_SLOT_MAX && $PG_SLOT_MAX != -1 ]] ; then
               if [[ ${PGSLOT//.} > ${PG_SLOT_MAX//.} ]] ; then
                       eerror "You must build ${CATEGORY}/${PN} against PostgreSQL ${PG_SLOT_MAX} or lower."
                       eerror "Set an appropriate slot with postgresql-config."
               fi
       fi

       if [[ -n $PG_SLOT_SOFT_MAX ]] ; then
               if [[ ${PGSLOT//.} > ${PG_SLOT_SOFT_MAX//.} ]] ; then
                       ewarn "You are building ${CATEGORY}/${PN} against a version of PostgreSQL greater than ${PG_SLOT_SOFT_MAX}."
                       ewarn "This is neither supported here nor upstream."
                       ewarn "Any bugs you encounter should be reported upstream."
               fi
       fi


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

_postgres_make() {
	emake PG_CONFIG=${PG_CONFIG}
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
