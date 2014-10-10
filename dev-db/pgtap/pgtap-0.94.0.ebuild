# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/pgtap/pgtap-0.93.0.ebuild,v 1.2 2013/05/01 10:32:11 ago Exp $

EAPI=5
inherit eutils

DESCRIPTION="Unit testing for PostgreSQL"
HOMEPAGE="http://pgtap.org/"
SRC_URI="http://api.pgxn.org/dist/${PN}/${PV}/${P}.zip"

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=virtual/postgresql-8.4
		dev-perl/TAP-Parser-SourceHandler-pgTAP
"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/pgtap-pg_config_override.patch"

	local pgslots=$(eselect --brief postgresql list)
	local pgslot
	for pgslot in ${pgslots} ; do
		mkdir -p "${WORKDIR}/${pgslot}"
		cp -R "${S}" "${WORKDIR}/${pgslot}"
	done
}

src_configure() {
	:
}

src_compile() {
	local pgslots=$(eselect --brief postgresql list)
	local pgslot
	for pgslot in ${pgslots} ; do
		cd "${WORKDIR}/${pgslot}/${P}"
		PG_CONFIG="pg_config${pgslot//.}" emake
	done
}

src_install() {
	local pgslots=$(eselect --brief postgresql list)
	local pgslot
	for pgslot in ${pgslots} ; do
		cd "${WORKDIR}/${pgslot}/${P}"
		PG_CONFIG="pg_config${pgslot//.}" emake DESTDIR="${D}" install
	done
}
