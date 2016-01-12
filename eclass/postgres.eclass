# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit user

# @ECLASS: postgres
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass for PostgreSQL-related packages
# @DESCRIPTION:
# This eclass provides common utility functions that many
# PostgreSQL-related packages perform, such as checking that the
# currently selected PostgreSQL slot is within a range, adding a system
# user to the postgres system group, and generating dependencies.


case ${EAPI:-0} in
  0|1|2|3|4) die "postgres.eclass requires EAPI 5 or higher" ;;
  *) ;;
esac


# @ECLASS-VARIABLE: POSTGRES_COMPAT
# @DESCRIPTION:
# A Bash array containing a list of compatible PostgreSQL slots as
# defined by the developer.

# @ECLASS-VARIABLE: POSTGRES_DEP
# @DESCRIPTION:
# An automatically generated dependency string suitable for use in
# DEPEND and RDEPEND declarations.

# @ECLASS-VARIABLE: POSTGRES_USEDEP
# @DESCRIPTION:
# Add the given, without brackets, 2-Style and/or 4-Style use
# dependencies to POSTGRES_DEP

if declare -p POSTGRES_COMPAT &> /dev/null ; then
	# Reverse sort the given POSTGRES_COMPAT so that the most recent
	# slot is preferred over an older slot.
	readarray -t POSTGRES_COMPAT < <(printf '%s\n' "${POSTGRES_COMPAT[@]}" | sort -nr)

	POSTGRES_DEP="|| ("
	for slot in "${POSTGRES_COMPAT[@]}" ; do
		POSTGRES_DEP+=" dev-db/postgresql:${slot}="
		declare -p POSTGRES_USEDEP &>/dev/null && \
			POSTGRES_DEP+="[${POSTGRES_USEDEP}]"
	done
	POSTGRES_DEP+=" )"
else
	POSTGRES_DEP="dev-db/postgresql"
	declare -p POSTGRES_USEDEP &>/dev/null && \
		POSTGRES_DEP+="[${POSTGRES_USEDEP}]"
fi


# @FUNCTION: postgres_check_slot
# @DESCRIPTION:
# Verify that the currently selected PostgreSQL slot is set to one of
# the slots defined in POSTGRES_COMPAT. Automatically dies unless a
# POSTGRES_COMPAT slot is selected. Should be called in pkg_pretend().
postgres_check_slot() {
	if ! declare -p POSTGRES_COMPAT &>/dev/null; then
		die 'POSTGRES_COMPAT not declared.'
	fi

	# Don't die because we can't run postgresql-config during pretend.
	[[ "$EBUILD_PHASE" = "pretend" && -z "$(which postgresql-config 2> /dev/null)" ]] \
		&& return 0

	if has $(postgresql-config show 2> /dev/null) "${POSTGRES_COMPAT[@]}"; then
		return 0
	else
		eerror "PostgreSQL slot must be set to one of: "
		eerror "    ${POSTGRES_COMPAT[@]}"
		die "Incompatible PostgreSQL slot eselected"
	fi
}

# @FUNCTION: postgres_new_user
# @DESCRIPTION:
# Creates the "postgres" system group and user -- which is separate from
# the database user -- in addition to the developer defined user. Takes
# the same arguments as "enewuser".
postgres_new_user() {
	enewgroup postgres 70
	enewuser postgres 70 /bin/bash /var/lib/postgresql postgres

	if [[ $# -gt 0 ]] ; then
		if [[ "$1" = "postgres" ]] ; then
			ewarn "Username 'postgres' implied, skipping"
		else
			local groups=$5
			[[ -n "${groups}" ]] && groups+=",postgres" || groups="postgres"
			enewuser $1 $2 $3 $4 ${groups}
		fi
	fi
}
