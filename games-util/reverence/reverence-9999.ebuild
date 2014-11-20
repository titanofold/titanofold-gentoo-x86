# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit git-r3 distutils-r1

DESCRIPTION="Python library for processing EVE Online cache and bulk data"
HOMEPAGE="https://github.com/ntt/reverence"
EGIT_REPO_URI="https://github.com/ntt/reverence.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""

RDEPEND="${PYTHON_DEPS}
dev-python/pyyaml[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
