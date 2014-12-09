# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VALA_MIN_API_VERSION="0.24"

inherit gnome2 vala versionator

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="A new calendar application for GNOME 3"
HOMEPAGE="https://wiki.gnome.org/Apps/California"
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="unity"

RDEPEND="
>=dev-libs/glib-2.38:2
>=dev-libs/gobject-introspection-1.38.0
>=dev-libs/libgdata-0.14.0
>=dev-libs/libgee-0.10.5:0.8
>=net-libs/gnome-online-accounts-3.8.3
>=net-libs/libsoup-2.44
>=x11-libs/gtk+-3.12.2:3
>=gnome-extra/evolution-data-server-3.8.5[vala]
x11-themes/gnome-themes-standard
"
DEPEND="${RDEPEND}
$(vala_depend)
>=dev-util/intltool-0.35.0
dev-lang/perl
dev-libs/libxml2
dev-perl/XML-Parser
dev-util/itstool
sys-devel/gettext
virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	epatch "${FILESDIR}"/relocate-docdir.patch
}

src_configure() {
	econf --docdir="${EPREFIX%/}/usr/share/doc/${PF}" \
		$(use_enable unity)
}

src_install() {
	gnome2_src_install
}
