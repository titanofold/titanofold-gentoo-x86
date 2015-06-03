# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit git-r3 distutils-r1

DESCRIPTION="EVE Market Data Uploader"
HOMEPAGE="https://github.com/gtaylor/EVE-Market-Data-Uploader"
EGIT_REPO_URI="https://github.com/gtaylor/EVE-Market-Data-Uploader.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""

RDEPEND="${PYTHON_DEPS}
dev-python/requests[${PYTHON_USEDEP}]
dev-python/watchdog[${PYTHON_USEDEP}]
games-util/emds[${PYTHON_USEDEP}]
games-util/reverence[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
