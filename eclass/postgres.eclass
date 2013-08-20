# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit user

# @ECLASS: postgres
# @MAINTAINER:
# PostgreSQL <pgsql-bugs@gentoo.org>
# @AUTHOR: Aaron W. Swenson <titanofold@gentoo.org>
# @BLURB: An eclass for PostgreSQL-related packages
# @DESCRIPTION:
# This eclass provides common utility functions that many
# PostgreSQL-related packages perform, such as checking that the
# currently selected PostgreSQL slot is within a range, adding a user,
# and generating dependencies.

# @FUNCTION: postgres_check_slot
# @DESCRIPTION:
# Verify that the currently selected PostgreSQL slot is set to one of
# the slots defined in POSTGRES_COMPAT.
postgres_check_slot() {
	if ! declare -p POSTGRES_COMPAT &>/dev/null; then
		die 'POSTGRES_COMPAT not declared.'
	fi

# Don't die because we can't run postgresql-config during pretend.
[[ "$EBUILD_PHASE" = "pretend" && -z "$(which postgresql-config 2> /dev/null)" ]] \
	&& return 0

	local res=$(echo ${POSTGRES_COMPAT[@]} \
		| grep -c $(postgresql-config show 2> /dev/null) 2> /dev/null)

	if [[ "$res" -eq "0" ]] ; then
			eerror "PostgreSQL slot must be set to one of: "
			eerror "    ${POSTGRES_COMPAT[@]}"
			return 1
	fi

	return 0
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
			ewarn "Invalid username 'postgres', skipping"
		else
			local groups=$5
			[[ -n "${groups}" ]] && groups+=",postgres" || groups="postgres"
			enewuser $1 $2 $3 $4 ${groups}
		fi
	fi
}
