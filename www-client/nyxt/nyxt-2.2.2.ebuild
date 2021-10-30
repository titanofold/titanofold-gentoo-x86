# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit common-lisp-3

DESCRIPTION="A keyboard-oriented, infinitely extensible web browser designed for power users."
HOMEPAGE="https://nyxt.atlas.engineer/"
SRC_URI="https://github.com/atlas-engineer/${PN}/releases/download/${PV}/${P}-source-with-submodules.tar.xz"

LICENSE="BSD CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
>=dev-lisp/sbcl-2.0.0
dev-libs/gobject-introspection
gnome-base/gsettings-desktop-schemas
net-libs/glib-networking
net-libs/webkit-gtk
"
DEPEND="${RDEPEND}
dev-libs/libfixposix
"

S="${WORKDIR}"

src_compile() {
	emake all
}

src_install() {
	default
}
