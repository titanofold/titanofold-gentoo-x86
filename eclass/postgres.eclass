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

# @ECLASS-VARIABLE: POSTGRES_COMPAT
# @REQUIRED
# @DESCRIPTION:
# POSTGRES_COMPAT is an array containing the list of PostgreSQL slots
# with which the package is compatible.

# @ECLASS-VARIABLE: POSTGRES_USEDEP
# @DESCRIPTION:
# POSTGRES_USEDEP is a developer-defined, comma-seperated list of USE
# flags in the same style as for Portage to toggle USE flag dependencies
# for dev-db/postgresql{,-base,-docs,-server}

# @ECLASS-VARIABLE: POSTGRES_DEPEND
# @DESCRIPTION:
# Eclass generated variable using the values in POSTGRES_COMPAT and
# POSTGRES_USEDEP to craft a suitable dependency string to be used in
# *DEPEND in your ebuild.

if declare -p POSTGRES_COMPAT &> /dev/null ; then
	# We prefer newer over older
	readarray -t POSTGRES_COMPAT < <(printf '%s\n' "${POSTGRES_COMPAT[@]}" | sort -nr)

	POSTGRES_DEPEND="|| ("
	for _slot in "${POSTGRES_COMPAT[@]}" ; do
		POSTGRES_DEPEND+=" dev-db/postgresql:${_slot}"
		declare -p POSTGRES_USEDEP &> /dev/null \
			&& POSTGRES_DEPEND+="[${POSTGRES_USEDEP}]"
	done
	POSTGRES_DEPEND+=" )"
else
	die 'POSTGRES_COMPAT not declared.'
fi

# @ECLASS-VARIABLE: _POSTGRES_ALL_SLOTS
# @INTERNAL
# @DESCRIPTION:
# Contains a list of all available slots installed on the system.

_POSTGRES_ALL_SLOTS=( $(eselect --brief postgresql list) )

# Reverse the list so that the first entry is the latest available release.
readarray -t _POSTGRES_ALL_SLOTS < <(printf '%s\n' "${_POSTGRES_ALL_SLOTS[@]}" | sort -nr)

# @FUNCTION: postgres_single_slot_pkg_setup
# @DESCRIPTION:
# This function should not be used for multi-slot ebuilds.
# Sets PG_CONFIG and PG_SLOT to the highest slot defined in
# POSTGRES_COMPAT and is installed on the host system. It should be
# called in pkg_setup() for single-slot ebuilds.

# @ECLASS-VARIABLE: PG_CONFIG
# @DESCRIPTION:
# Exported environment variable that contains the pg_config command
# selected by postgres_single_slot_pkg_setup().

# @ECLASS-VARIABLE: PG_SLOT
# @DESCRIPTION:
# Exported environment variable that contains the PostgreSQL slot
# selelected by postgres_single_slot_pkg_setup().

postgres_single_slot_pkg_setup() {
	export PG_SLOT="${_POSTGRES_ALL_SLOTS[0]}"
	export PG_CONFIG="pg_config${_POSTGRES_ALL_SLOTS[0]//./}"

	if [[ -z ${PG_SLOT} ]]; then
		eerror "You don't have any suitable PostgreSQL slots installed. You should"
		eerror "install one of the following PostgreSQL slots:"
		eerror "    ${POSTGRES_COMPAT}"
		die
	fi
}

# @FUNCTION: add_postgres_usergroup
# @DESCRIPTION:
# Creates the "postgres" system group and user. This is separate from
# PostgreSQL's "postgres" database role.

add_postgres_usergroup() {
	enewgroup postgres 70
	enewuser postgres 70 /bin/bash /var/lib/postgresql postgres
}
