# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

POSTGRES_COMPAT=( 9.{1,2,3,4,5,6} )

WX_GTK_VER="3.0"

inherit eutils multilib postgres versionator wxwidgets

DESCRIPTION="wxWidgets GUI for PostgreSQL"
HOMEPAGE="http://www.pgadmin.org/"
SRC_URI="mirror://postgresql/${PN}/release/v${PV}/src/${P}.tar.gz"

LICENSE="POSTGRESQL"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
SLOT="0"
IUSE="debug +databasedesigner"

DEPEND="${POSTGRES_DEPEND}
	x11-libs/wxGTK:${WX_GTK_VER}=[X]
	>=dev-libs/libxml2-2.6.18
	>=dev-libs/libxslt-1.1"
RDEPEND="${DEPEND}"


src_prepare() {
	epatch "${FILESDIR}/pgadmin3-desktop.patch"

	epatch_user
}

src_configure() {
	need-wxwidgets unicode

	econf --with-pgsql="$(${PG_CONFIG} --bindir|sed 's|/bin||')" \
		  --with-wx-version=${WX_GTK_VER} \
		$(use_enable debug) \
		$(use_enable databasedesigner)
}

src_install() {
	emake DESTDIR="${D}" install

	newicon "${S}/pgadmin/include/images/pgAdmin3.png" ${PN}.png

	domenu "${S}/pkg/pgadmin3.desktop"

	# Fixing world-writable files
	fperms -R go-w /usr/share
}
