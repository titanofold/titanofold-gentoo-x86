# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
POSTGRES_COMPAT=( 9.{1..6} )

inherit eutils cmake-utils postgres-multi

DESCRIPTION="pgRouting extends PostGIS and PostgreSQL with geospatial routing functionality."
HOMEPAGE="http://pgrouting.org/index.html"
LICENSE="GPL-2 MIT Boost-1.0"

SLOT="0"
KEYWORDS="~amd64 ~x86"
SRC_URI="https://github.com/pgRouting/${PN}/archive/${P}.tar.gz"
IUSE="+drivingdistance doc pdf html"

REQUIRED_USE="html? ( doc ) pdf? ( doc )"

RDEPEND="${POSTGRES_DEP}
	>=dev-db/postgis-2.0
	dev-libs/boost
	drivingdistance? ( sci-mathematics/cgal )
"

DEPEND="${POSTGRES_DEP}
	doc? ( >=dev-python/sphinx-1.1 )
	pdf? ( >=dev-python/sphinx-1.1[latex] )
"

# Needs a running psql instance, doesn't work out of the box
RESTRICT="test"
CMAKE_MIN_VERSION="2.8.8"

S="${WORKDIR}/${PN}-${P}"

src_prepare() {
	epatch "${FILESDIR}/pgrouting-2.3.0-try_pg_config_envvar.patch"

	postgres-multi_src_prepare
	postgres-multi_foreach cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_DD="$(usex drivingdistance)"
		-DWITH_DOC="$(usex doc)"
		-DBUILD_MAN="$(usex doc)"
		-DBUILD_HTML="$(usex html)"
		-DBUILD_LATEX="$(usex pdf)"
	)

	postgres-multi_foreach cmake-utils_src_configure
}

src_compile() {
	local make_opts
	use doc && make_opts="all doc"
	postgres-multi_foreach cmake-utils_src_make ${make_opts}
}

src_install() {
	use doc && doman "${BUILD_DIR}"/doc/man/en/pgrouting.7
	use html && dohtml -r "${BUILD_DIR}"/doc/html/*
	use pdf && dodoc "${BUILD_DIR}"/doc/latex/en/*.pdf

	dodoc README* VERSION

	postgres-multi_foreach cmake-utils_src_install
}
