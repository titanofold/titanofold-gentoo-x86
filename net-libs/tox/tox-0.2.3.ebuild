# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils systemd user

DESCRIPTION="Encrypted P2P, messaging, and audio/video calling platform"
HOMEPAGE="https://tox.chat"
SRC_URI="https://github.com/TokTok/c-toxcore/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0/0.1"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="address-sanitizer +av daemon debug dht static-libs test"

RDEPEND="
	av? ( media-libs/libvpx:=
		media-libs/opus )
	daemon? ( dev-libs/libconfig )
	>=dev-libs/libsodium-0.6.1:=[asm,urandom]"
DEPEND="${RDEPEND}
	test? ( dev-libs/check )
	virtual/pkgconfig"

S="${WORKDIR}/c-toxcore-${PV}"

src_configure() {
	local mycmakeargs=(
		-DASAN=$(usex address-sanitizer)
		-DBOOTSTRAP_DAEMON=$(usex daemon)
		-DBUILD_TOXAV=$(usex av)
		-DDEBUG=$(usex debug)
		-DDHT_BOOTSTRAP=$(usex dht)
		-DENABLE_STATIC=$(usex static-libs)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use daemon; then
		newinitd "${FILESDIR}"/initd tox-dht-daemon
		newconfd "${FILESDIR}"/confd tox-dht-daemon
		insinto /etc
		doins "${FILESDIR}"/tox-bootstrapd.conf
		systemd_dounit "${FILESDIR}"/tox-bootstrapd.service
	fi

	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	if use daemon; then
		enewgroup ${PN}
		enewuser ${PN} -1 -1 -1 ${PN}
		if [[ -f ${EROOT%/}/var/lib/tox-dht-bootstrap/key ]]; then
			ewarn "Backwards compatability with the bootstrap daemon might have been"
			ewarn "broken a while ago. To resolve this issue, REMOVE the following files:"
			ewarn "    ${EROOT%/}/var/lib/tox-dht-bootstrap/key"
			ewarn "    ${EROOT%/}/etc/tox-bootstrapd.conf"
			ewarn "    ${EROOT%/}/run/tox-dht-bootstrap/tox-dht-bootstrap.pid"
			ewarn "Then just reinstall net-libs/tox"
		fi
	fi
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
