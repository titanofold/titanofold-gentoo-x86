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

# Add doc back in for 3.0 and bump app-doc/gnucash-docs
IUSE="aqbanking chipcard debug gnome-keyring mysql nls ofx postgres python
	  quotes register2 sqlite"
REQUIRED_USE="
	chipcard? ( aqbanking )
	python? ( ${PYTHON_REQUIRED_USE} )"

# libdbi version requirement for sqlite taken from bug #455134
#
# dev-libs/boost must always be built with nls enabled.
RDEPEND="
	>=dev-cpp/gtest-1.8.0-r1[source]
	>=dev-libs/glib-2.40.0:2
	>=dev-libs/libxml2-2.7.0:2
	>=dev-scheme/guile-2.0.0:12=[regex]
	>=sys-libs/zlib-1.1.4
	>=x11-libs/goffice-0.7.0:0.8[gnome]
	>=x11-libs/gtk+-3.14.0:3
	dev-libs/boost:=[icu,nls]
	dev-libs/icu:=
	dev-libs/libxslt
	gnome-base/dconf
	net-libs/webkit-gtk:4=
	aqbanking? (
		>=net-libs/aqbanking-5[gtk,ofx?]
		sys-libs/gwenhywfar[gtk]
		chipcard? ( sys-libs/libchipcard )
	)
	gnome-keyring? ( >=app-crypt/libsecret-0.18 )
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
	dev-lang/perl
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

src_prepare() {
	# We need to run eautoreconf to prevent linking against system libs,
	# this can be noticed, for example, when updating an old version
	# compiled against guile-1.8 to a newer one relying on 2.0
	# https://bugs.gentoo.org/show_bug.cgi?id=590536#c39
	# https://bugzilla.gnome.org/show_bug.cgi?id=775634
	eautoreconf

	gnome2_src_prepare
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
		$(use_enable nls) \
		$(use_enable debug) \
		$(use_enable gnome-keyring password-storage) \
		$(use_enable aqbanking) \
		$(use_enable ofx) \
		$(use_enable python) \
		$(use_enable register2) \
		${myconf}
}

src_install() {
	gnome2_src_install

	rm -r "${ED}"/usr/share/doc/${PF}/{COPYING,INSTALL,*win32-bin.txt,projects.html} || die
	mv "${ED}"/usr/share/doc/${PF} "${T}"/cantuseprepalldocs || die
	dodoc "${T}"/cantuseprepalldocs/*
}