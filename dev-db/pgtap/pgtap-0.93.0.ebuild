# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
POSTGRES_COMPAT=( 9.{1,2,3} )
inherit eutils postgres

DESCRIPTION="Unit testing for PostgreSQL"
HOMEPAGE="http://pgtap.org/"
SRC_URI="http://api.pgxn.org/dist/${PN}/${PV}/${P}.zip"
LICENSE="POSTGRESQL"
KEYWORDS="~amd64"
IUSE=""
SLOT="0"

DEPEND=">=dev-db/postgresql-base-8.4
		dev-perl/TAP-Parser-SourceHandler-pgTAP
"
RDEPEND="${DEPEND}"

src_prepare() {
	postgres_src_prepare
	postgres_foreach_impl run_in_build_dir epatch "${FILESDIR}/pgtap-pg_config_override.patch"
}
