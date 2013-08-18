# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/geos/geos-3.3.7.ebuild,v 1.1 2013/02/02 06:04:19 patrick Exp $

EAPI="5"

PYTHON_COMPAT=( python3_{1,2,3} )
inherit autotools eutils python-single-r1

DESCRIPTION="Geometry engine library for Geographic Information Systems"
HOMEPAGE="http://trac.osgeo.org/geos/"
SRC_URI="http://download.osgeo.org/geos/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x64-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris"
IUSE="doc php python ruby static-libs"

RDEPEND="
	php? ( >=dev-lang/php-5.3[-threads] )
	ruby? ( dev-lang/ruby )
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	php? ( dev-lang/swig )
	python? ( dev-lang/swig )
	ruby? ( dev-lang/swig )
"

src_prepare() {
	epatch "${FILESDIR}"/3.4.0-solaris-isnan.patch #\
		#"${FILESDIR}"/3.4.0-configure-macro.patch
	eautoreconf
	echo "#!${EPREFIX}/bin/bash" > py-compile
}

src_configure() {
	econf \
		$(use_enable python) \
		$(use_enable ruby) \
		$(use_enable php) \
		$(use_enable static-libs static)
}

src_compile() {
	emake

	use doc && emake -C "${S}/doc" doxygen-html
}

src_install() {
	emake DESTDIR="${D}" install

	use doc && dohtml -r doc/doxygen_docs/html/*

	find "${ED}" -name '*.la' -exec rm -f {} +
}