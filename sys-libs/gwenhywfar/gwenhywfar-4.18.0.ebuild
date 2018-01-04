# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils

MY_P="${P/_beta/beta}"
DESCRIPTION="A multi-platform helper library for other libraries"
HOMEPAGE="http://www.aquamaniac.de/aqbanking/"
SRC_URI="https://www.aquamaniac.de/sites/download/download.php?package=01&release=206&file=01&dummy=gwenhywfar-4.18.0.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug doc fox gtk qt4 qt5"

RDEPEND="dev-libs/libgpg-error
	dev-libs/libgcrypt:0=
	dev-libs/openssl:0=
	net-libs/gnutls:=
	virtual/libiconv
	virtual/libintl
	fox? ( x11-libs/fox:1.6 )
	gtk? ( x11-libs/gtk+:2 )
	qt4? ( dev-qt/qtgui:4 )
	qt5? ( dev-qt/qtgui:5 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

# broken upstream, reported but got no reply
RESTRICT="test"

src_configure() {
	local guis
	local extra_opts
	use fox && guis+=" fox16"
	use gtk && guis+=" gtk2"
	if use qt4 ; then
		guis="${guis} qt4"
		extra_opts+=" --with-qt4-moc=\"$(qt4_get_bindir)/moc\""
	fi

	if use qt5 ; then
		guis="${guis} qt5"
		extra_opts+=" --with-qt5-qmake=$(qt5_get_bindir)/qmake"
		extra_opts+=" --with-qt5-moc=$(qt5_get_bindir)/moc"
		extra_opts+=" --with-qt5-uic=$(qt5_get_bindir)/uic"
	fi

	econf \
		--enable-ssl \
		--with-docpath="${EPREFIX}/usr/share/doc/${PF}/apidoc" \
		$(use_enable debug) \
		$(use_enable doc full-doc) \
		${extra_opts} \
		--with-guis="${guis}"
}

src_compile() {
	emake

	use doc && emake srcdoc
}

src_install() {
	default

	use doc && emake DESTDIR="${D}" install-srcdoc

	find "${ED}" -name '*.la' -delete || die
}
