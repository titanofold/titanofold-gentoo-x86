# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit gnome2-utils python-single-r1 scons-utils

DESCRIPTION="Remove duplicates and other lint from your filesystem"
HOMEPAGE="http://rmlint.readthedocs.io/en/latest/"
SRC_URI="https://github.com/sahib/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gui"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
>=dev-libs/glib-2.32:2=
dev-libs/json-glib
sys-apps/util-linux
virtual/libelf
gui? (
	 >=x11-libs/gtk+-3.12:3=
	 gnome-base/librsvg:2=
	 $(python_gen_cond_dep '
		 dev-python/colorlog[${PYTHON_USEDEP}]
		 dev-python/pygobject:3=[${PYTHON_USEDEP}]

	 ')
)
"
DEPEND="${RDEPEND}
$(python_gen_cond_dep '
	dev-python/sphinx[${PYTHON_USEDEP}]
')
sys-devel/gettext
virtual/pkgconfig
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default

	sed "/conf.env.Append(LINKFLAGS=\['-s'\])/d" -i SConstruct
}

src_configure() {
	local o_option=$(echo ${CFLAGS} | sed 's/.*-O\([s0-3]\).*/\1/')
	MYSCONS=(
		O=$o_option
		--actual-prefix="%{EROOT%/}/usr"
		--prefix="${ED%/}/usr"
		$(use_with gui)
	)
}

src_compile() {
	escons "${MYSCONS[@]}"
}

src_install() {
	escons "${MYSCONS[@]}" DESTDIR="${D}" install
	if use gui ; then
		rm "${ED}"/usr/share/glib-2.0/schemas/gschemas.compiled || die
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}
