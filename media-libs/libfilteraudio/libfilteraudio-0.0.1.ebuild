# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MY_P="filter_audio"
SRC_URI="https://github.com/irungentoo/${MY_P}/archive/v${PV}.tar.gz"

DESCRIPTION="Lightweight audio filtering library made from webrtc code."
HOMEPAGE="https://github.com/irungentoo/${MY_P}"

LICENSE="BSD"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"

S=${WORKDIR}/${MY_P}-${PV}/

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" LIBDIR="$(get_libdir)" install
}
