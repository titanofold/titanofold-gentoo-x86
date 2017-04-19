# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

MY_P="uTox"

DESCRIPTION="Lightweight Tox client"
HOMEPAGE="https://github.com/uTox/uTox"
SRC_URI="https://github.com/uTox/uTox/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
IUSE="+dbus +filter_audio"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	media-libs/freetype
	media-libs/libv4l
	media-libs/libvpx
	media-libs/openal
	net-libs/tox:0/0.1[av]
	x11-libs/libX11
	x11-libs/libXext
	dbus? ( sys-apps/dbus )
	filter_audio? ( media-libs/libfilteraudio )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}-${PV}"

src_prepare() {
	eapply_user

	cmake-utils_src_prepare
}

src_configure() {
	if use filter_audio && [[ ${PROFILE_IS_HARDENED} -eq 1 ]]; then
		ewarn "Building µTox with support for filter_audio using hardened profile results in"
		ewarn "crash upon start. For details, see https://github.com/notsecure/uTox/issues/844"
	fi

	local mycmakeargs=(
		HAVE_DBUS=$(usex dbus "1" "0")
		FILTER_AUDIO=$(usex filter_audio "1" "0")
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	local size
	for size in 16 22 24 32 36 48 64 72 96 128 192 256 512 ; do
		newicon -s ${size} icons/utox-${size}x${size}.png utox.png
	done
	doicon -s scalable icons/utox.svg
}
