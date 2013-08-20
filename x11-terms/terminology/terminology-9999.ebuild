# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminology/terminology-0.3.0.ebuild,v 1.3 2013/04/12 03:31:14 fauli Exp $

EAPI=5

inherit autotools git-2
EGIT_REPO_URI="git://git.enlightenment.org/apps/terminology.git"

DESCRIPTION="Feature rich terminal emulator using the Enlightenment Foundation Libraries"
HOMEPAGE="http://www.enlightenment.org/p.php?p=about/terminology"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS=""
IUSE=""

EFL_VERSION=1.7.0

RDEPEND="
	>=dev-libs/ecore-${EFL_VERSION}[evas]
	>=dev-libs/eet-${EFL_VERSION}
	>=dev-libs/efreet-${EFL_VERSION}
	>=dev-libs/eina-${EFL_VERSION}
	>=media-libs/edje-${EFL_VERSION}
	>=media-libs/elementary-${EFL_VERSION}
	>=media-libs/emotion-${EFL_VERSION}
	>=media-libs/ethumb-${EFL_VERSION}[dbus]
	>=media-libs/evas-${EFL_VERSION}"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
}
