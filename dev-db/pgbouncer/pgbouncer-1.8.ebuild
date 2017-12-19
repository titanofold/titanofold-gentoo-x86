# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils user

DESCRIPTION="Lightweight connection pooler for PostgreSQL"
HOMEPAGE="https://pgbouncer.github.io"
SRC_URI="https://pgbouncer.github.io/downloads/files/${PV}/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+c-ares debug doc pam ssl -udns"

# At-most-one-of, one can be enabled but not both
REQUIRED_USE="?? ( c-ares udns )"

RDEPEND="
	>=dev-libs/libevent-2.0
	>=sys-libs/glibc-2.10
	c-ares? ( >=net-dns/c-ares-1.10 )
	udns? ( >=net-libs/udns-0.1 )
"

DEPEND="
	${RDEPEND}
	>=app-text/asciidoc-8.4
	app-text/docbook-xml-dtd:4.5
	app-text/xmlto
"

pkg_setup() {
	enewgroup postgres 70
	enewuser postgres 70 /bin/bash /var/lib/postgresql postgres

	enewuser pgbouncer -1 -1 -1 postgres
}

src_prepare() {
	eapply "${FILESDIR}/pgbouncer-dirs-1.8.patch" \
		   "${FILESDIR}/pgbouncer-1.8-missing-pam-h.patch"

	eapply_user
}

src_configure() {
	# --enable-debug is only used to disable stripping
	econf \
		--docdir=/usr/share/doc/${PF} \
		--enable-debug \
		$(use_with c-ares cares) \
		$(use_enable debug cassert) \
		$(use_with pam) \
		$(use_with ssl openssl) \
		$(use_with udns)
}

src_test() {
	cd "${S}/test"
	emake
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS

	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"

	insinto /etc
	doins etc/pgbouncer.ini

	insinto /etc/logrotate.d
	newins "${FILESDIR}/logrotate" pgbouncer
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		einfo "Please read the config.txt for Configuration Directives"
		einfo
		einfo "For Administration Commands, see:"
		einfo "    man pgbouncer"
		einfo
		einfo "By default, PgBouncer does not have access to any database."
		einfo "GRANT the permissions needed for your application and make sure that it"
		einfo "exists in PgBouncer's auth_file."
	fi
}
