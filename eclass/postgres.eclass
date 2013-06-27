# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python-single-r1.eclass,v 1.18 2013/05/21 01:31:02 floppym Exp $

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

#case "${EAPI:-0}" in
#	0|1|2|3|4)
#		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}"
#		;;
#	5)
#		# EAPI=5 is required for meaningful USE default deps
#		# on USE_EXPAND flags
#		;;
#	*)
#		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
#		;;
#esac

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
}
