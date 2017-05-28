# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="Flask-Gravatar"
MY_P=${MY_PN}-${PV}

PYTHON_COMPAT=( python{2_7,3_4,3_5} )
inherit distutils-r1

DESCRIPTION="Small extension for Flask to make usage of Gravatar service easy"
HOMEPAGE="https://github.com/zzzsochi/Flask-Gravatar/"
SRC_URI="mirror://pypi/F/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/flask[${PYTHON_USEDEP}]"

S=${WORKDIR}/${MY_P}
