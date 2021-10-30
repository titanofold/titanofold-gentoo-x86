# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Thin wrapper over POSIX syscalls."
HOMEPAGE="https://github.com/sionescu/libfixposix"
SRC_URI="https://github.com/sionescu/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="test? ( test )"

RDEPEND=""
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-libs/check )
"

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	econf $(use_enable test tests)
}
