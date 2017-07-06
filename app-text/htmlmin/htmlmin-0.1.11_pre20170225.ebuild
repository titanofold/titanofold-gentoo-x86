# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 vcs-snapshot

HTMLMIN_GIT_REVISION="6831a2b5d30c77e12de1733768a0805747eb559a"

DESCRIPTION="A configurable HTML Minifier with safety features"
HOMEPAGE="https://htmlmin.readthedocs.org/en/latest/"
SRC_URI="https://github.com/mankyd/${PN}/archive/${HTMLMIN_GIT_REVISION}.tar.gz
			 -> ${P}.tar.gz"

LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

src_prepare() {
	sed '/prune/d' -i MANIFEST.in
	default
}
