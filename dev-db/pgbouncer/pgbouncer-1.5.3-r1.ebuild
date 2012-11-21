# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/pgbouncer/pgbouncer-1.5.2.ebuild,v 1.1 2012/06/18 07:53:26 patrick Exp $

EAPI="4"

# Upstream has *way* broken tests.
RESTRICT="test"

inherit user

DESCRIPTION="Lightweight connection pooler for PostgreSQL"
HOMEPAGE="http://pgfoundry.org/projects/pgbouncer/"
SRC_URI="mirror://postgresql/projects/pgFoundry/${PN}/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug libevent udns"

DEPEND=">=dev-libs/glibc-2.10
		libevent? ( >=dev-libs/libevent-2.0 )
		udns? ( >=net-libs/udns-0.1 )"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup postgres 70
	enewuser postgres 70 /bin/bash /var/lib/postgresql postgres
}

src_prepare() {
	local rundir
	[[ ! -d /run ]] && rundir=/var

	sed -i -e "s,${PN}.log,/var/log/${PN}/${PN}.log," \
		-e "s,${PN}.pid,/var/run/${PN}/${PN}.pid," \
		-e "s,etc/userlist.txt,/etc/userlist.txt," \
		-e "s,;unix_socket_dir = /tmp,unix_socket_dir = ${rundir}/run/${PN}.sock," \
		"${S}"/etc/pgbouncer.ini || die
}

src_configure() {
	# --enable-debug is only used to disable stripping
	econf \
		--enable-debug \
		$(use_enable debug cassert) \
		--docdir=/usr/share/doc/${PF}
}

src_install() {
	emake DESTDIR="${D}" install

	insinto /etc
	doins etc/pgbouncer.ini
	newinitd "${FILESDIR}"/pgbouncer.initd "${PN}"

	dodoc README NEWS AUTHORS doc/*.txt
}

pkg_postinst() {
	einfo "Please read the config.txt for Configuration Directives"
	einfo
	einfo "For Administration Commands, see:"
	einfo "    man pgbouncer"
	einfo
	einfo "By default, PgBouncer does not have access to any database."
	einfo "GRANT the permissions needed for your application and make sure that it"
	einfo "exists in PgBouncer's auth_file."

	if [[ -n ${REPLACING_VERSIONS} ]] ; then
		local a
		local b
		local y
		for a in ${REPLACING_VERSION} ; do
			for b in 1.4.2 1.5 1.5.1 1.5.2 ; do
				[[ "${a}" == "${b}" ]] && y=1
			done
		done
		if [[ -n ${y} ]] ; then
			elog "Previous versions of this ebuild created the 'pgbouncer' user and user"
			elog "group. They can now be removed."
			elog "    # userdel pgbouncer && groupdel pgbouncer"
		fi
	fi
}
