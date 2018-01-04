# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 )

inherit autotools gnome2 python-single-r1

DESCRIPTION="A personal finance manager"
HOMEPAGE="http://www.gnucash.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

# Add doc back in for 3.0
IUSE="chipcard debug gnome-keyring hbci mysql ofx postgres python quotes sqlite"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# README.dependencies mentions qof, but ${PN} has their own fork in the
# source code that appears to have deviated from that project.
#
# libdbi version requirement for sqlite taken from bug #455134
RDEPEND="
	>=dev-cpp/gtest-1.8.0-r1[source]
	>=dev-libs/glib-2.40.0:2
	>=dev-libs/libxml2-2.7.0:2
	>=dev-scheme/guile-2.2.0:12=[regex]
	>=sys-libs/zlib-1.1.4
	>=x11-libs/goffice-0.7.0:0.8[gnome]
	>=x11-libs/gtk+-3.14.0:3
	dev-libs/boost:=[icu,nls]
	dev-libs/icu:=
	dev-libs/libxslt
	gnome-base/dconf
	net-libs/webkit-gtk:4=
	gnome-keyring? ( >=app-crypt/libsecret-0.18 )
	hbci? (
		>=net-libs/aqbanking-5[gtk,ofx?]
		sys-libs/gwenhywfar[gtk]
		chipcard? ( sys-libs/libchipcard )
	)
	mysql? (
		dev-db/libdbi
		dev-db/libdbi-drivers[mysql]
	)
	ofx? ( >=dev-libs/libofx-0.9.1 )
	postgres? (
		dev-db/libdbi
		dev-db/libdbi-drivers[postgres]
	)
	python? ( ${PYTHON_DEPS} )
	quotes? (
		>=dev-perl/Finance-Quote-1.11
		dev-perl/Date-Manip
		dev-perl/HTML-TableExtract
	)
	sqlite? (
		>=dev-db/libdbi-0.9.0
		>=dev-db/libdbi-drivers-0.9.0[sqlite]
	)
"

DEPEND="${RDEPEND}
	dev-util/intltool
	gnome-base/gnome-common
	sys-devel/libtool
	virtual/pkgconfig
"

# Uncomment for 3.0
# PDEPEND="doc? (
# 	~app-doc/gnucash-docs-${PV}
# 	gnome-extra/yelp
# )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local myconf

	DOCS="doc/README.OFX doc/README.HBCI"

	if use sqlite || use mysql || use postgres ; then
		myconf+=" --enable-dbi"
	else
		myconf+=" --disable-dbi"
	fi

	gnome2_src_configure \
		--disable-doxygen \
		--disable-error-on-warning \
		--disable-nls \
		$(use_enable debug) \
		$(use_enable gnome-keyring password-storage) \
		$(use_enable hbci aqbanking) \
		$(use_enable ofx) \
		$(use_enable python) \
		${myconf}
}

src_install() {
	gnome2_src_install

	rm -r "${ED}"/usr/share/doc/${PF}/{COPYING,INSTALL,*win32-bin.txt,projects.html} || die
	mv "${ED}"/usr/share/doc/${PF} "${T}"/cantuseprepalldocs || die
	dodoc "${T}"/cantuseprepalldocs/*
}
