# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
EGIT_REPO_URI='https://github.com/bsdphk/Ntimed.git'
inherit git-2

DESCRIPTION="Network time synchronization software, NTPD replacement"
HOMEPAGE="https://github.com/bsdphk/Ntimed"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS=""

DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
	bash configure
}

src_install() {
	dosbin ntimed-client

	newinitd "${FILESDIR}/ntimed-client.initd" ntimed-client
	newconfd "${FILESDIR}/ntimed-client.confd" ntimed-client

	dodoc README.rst
}
