# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

POSTGRES_COMPAT=( 9.{0,1,2,3,4,5} )

inherit postgres-multi

DESCRIPTION="Unit testing for PostgreSQL"
HOMEPAGE="http://pgtap.org/"
SRC_URI="http://api.pgxn.org/dist/${PN}/${PV}/${P}.zip"

LICENSE="POSTGRESQL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="${POSTGRES_DEPEND}
		dev-perl/TAP-Parser-SourceHandler-pgTAP
"
RDEPEND="${DEPEND}"

src_configure() {
	:
}
