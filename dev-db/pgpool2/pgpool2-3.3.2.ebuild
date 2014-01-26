# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/pgpool2/pgpool2-3.2.1.ebuild,v 1.2 2012/11/16 20:03:13 ago Exp $

EAPI=4
POSTGRES_COMPAT=( 8.4 9.{0,1,2,3} )

inherit base

MY_P="${PN/2/-II}-${PV}"

DESCRIPTION="Connection pool server for PostgreSQL"
HOMEPAGE="http://www.pgpool.net/"
SRC_URI="http://www.pgpool.net/download.php?f=${MY_P}.tar.gz -> ${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE="memcached pam ssl static-libs"

RDEPEND="
	<dev-db/postgresql-base-9.3
	memcached? ( dev-libs/libmemcached )
	pam? ( sys-auth/pambase )
	ssl? ( dev-libs/openssl )
"
DEPEND="${RDEPEND}
	sys-devel/bison
	!!dev-db/pgpool
"

S=${WORKDIR}/${MY_P}

postgres_check_slot() {
	if ! declare -p POSTGRES_COMPAT &>/dev/null; then
		die 'POSTGRES_COMPAT not declared.'
	fi

	local cur_slot=$(postgresql-config show 2> /dev/null)

	# Don't fail because we can't run postgresql-config during pretend.
	[[ "$EBUILD_PHASE" = "pretend" && -z "${cur_slot}" ]] && return 0

	local res=$(echo ${POSTGRES_COMPAT[@]} | grep -c "${cur_slot}" 2> /dev/null)

	if [[ "$res" -eq "0" ]] ; then
			eerror "PostgreSQL slot must be set to one of: "
			eerror "    ${POSTGRES_COMPAT[@]}"
			return 1
	fi

	return 0
}

pkg_pretend() { postgres_check_slot || die; }
pkg_setup() {
	postgres_check_slot || die

	enewgroup postgres 70
	enewuser pgpool -1 -1 -1 postgres

	# We need the postgres user as well so we can set the proper
	# permissions on the sockets without getting into fights with
	# PostgreSQL's initialization scripts.
	enewuser postgres 70 /bin/bash /var/lib/postgresql postgres
}

src_prepare() {
	epatch "${FILESDIR}/pgpool_run_paths.patch"

	local pg_config_manual="$(pg_config --includedir)/pg_config_manual.h"
	local pgsql_socket_dir=$(grep DEFAULT_PGSOCKET_DIR "${pg_config_manual}" | \
		sed 's|.*\"\(.*\)\"|\1|g')
	local pgpool_socket_dir="$(dirname $pgsql_socket_dir)/pgpool"

	sed "s|@PGSQL_SOCKETDIR@|${pgsql_socket_dir}|g" \
		-i *.conf.sample* pool.h || die

	sed "s|@PGPOOL_SOCKETDIR@|${pgpool_socket_dir}|g" \
		-i *.conf.sample* pool.h || die
}

src_configure() {
	local myconf
	use memcached && \
		myconf="--with-memcached=\"${EROOT%/}/usr/include/libmemcached\""
	use pam && myconf+=' --with-pam'

	econf \
		--disable-rpath \
		--sysconfdir="${EROOT%/}/etc/${PN}" \
		$(use_with ssl openssl) \
		$(use_enable static-libs static) \
		${myconf}
}

src_compile() {
	emake

	emake -C sql
}

src_install() {
	emake DESTDIR="${D}" install

	emake DESTDIR="${D}" -C sql install
	cd "${S}"

	# `contrib' moved to `extension' with PostgreSQL 9.1
	local pgslot=$(postgresql-config show)
	if [[ ${pgslot//.} > 90 ]] ; then
		cd "${ED%/}$(pg_config --sharedir)"
		mv contrib extension || die
		cd "${S}"
	fi

	newinitd "${FILESDIR}/${PN}.initd" ${PN}
	newconfd "${FILESDIR}/${PN}.confd" ${PN}

	# Documentation
	dodoc NEWS TODO doc/where_to_send_queries.{pdf,odg}
	dohtml -r doc

	# Examples and extras
	insinto "/usr/share/${PN}"
	doins doc/{pgpool_remote_start,basebackup.sh,recovery.conf.sample}
	mv "${ED%/}/usr/share/${PN/2/-II}" "${ED%/}/usr/share/${PN}" || die

	# One more thing: Evil la files!
	find "${ED}" -name '*.la' -exec rm -f {} +
}
