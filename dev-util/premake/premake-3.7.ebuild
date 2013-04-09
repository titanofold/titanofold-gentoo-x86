# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/premake/premake-3.5.ebuild,v 1.5 2012/05/01 18:12:34 ago Exp $

EAPI=5

inherit versionator

DESCRIPTION="A makefile generation tool"
HOMEPAGE="http://industriousone.com/premake"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.zip"

LICENSE="GPL-2"
SLOT=$(get_major_version)
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

S=${WORKDIR}/${P/p/P}

src_install() {
	dobin bin/${PN}
}
