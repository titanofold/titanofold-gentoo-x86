# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
POSTGRES_COMPAT=( 9.{0,1,2,3,4,5,6} )

inherit eutils cmake-utils

DESCRIPTION="pgRouting extends PostGIS and PostgreSQL with geospatial routing functionality."
HOMEPAGE="http://pgrouting.org/index.html"
LICENSE="GPL-2 MIT Boost-1.0"

SLOT="0"
KEYWORDS="~amd64 ~x86"
SRC_URI="https://github.com/pgRouting/pgrouting/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE="doc doc-pdf"

REQUIRED_USE="doc-pdf? ( doc )"

RDEPEND="
	|| (    
		dev-db/postgresql:9.6[server]
		dev-db/postgresql:9.5[server]
		dev-db/postgresql:9.4[server]
		dev-db/postgresql:9.5[server]
		dev-db/postgresql:9.2[server]
		dev-db/postgresql:9.1[server]
	)
	>=dev-db/postgis-2.0
	dev-libs/boost
	sci-mathematics/cgal
"

DEPEND="
	doc? ( >=dev-python/sphinx-1.1 )
	doc-pdf? ( >=dev-python/sphinx-1.1[latex] )
"

# Needs a running psql instance, doesn't work out of the box
RESTRICT="test"

postgres_check_slot() {
	if ! declare -p POSTGRES_COMPAT &>/dev/null; then
		die 'POSTGRES_COMPAT not declared.'
	fi

# Don't die because we can't run postgresql-config during pretend.
[[ "$EBUILD_PHASE" = "pretend" \
	&& -z "$(which postgresql-config 2> /dev/null)" ]] && return 0

	local res=$(echo ${POSTGRES_COMPAT[@]} \
		| grep -c $(postgresql-config show 2> /dev/null) 2> /dev/null)

	if [[ "$res" -eq "0" ]] ; then
			eerror "PostgreSQL slot must be set to one of: "
			eerror "    ${POSTGRES_COMPAT[@]}"
			return 1
	fi

	return 0
}

pkg_pretend() {
	postgres_check_slot || die
}

pkg_setup() {
	postgres_check_slot || die
}

#src_prepare() {
	# epatch "${FILESDIR}/no-contrib-when-use-extension.patch"

#}

src_configure() {
	einfo "patche ${S}/cmake/FindSphinx.cmake für python 3"
	sed -i -e 's|print sphinx.__version__|print (sphinx.__version__)|' "${S}/cmake/FindSphinx.cmake"
	local mycmakeargs=(
		$(cmake-utils_use_with doc DOC)
		$(cmake-utils_use_build doc MAN)
		$(cmake-utils_use_build doc HTML)
		$(cmake-utils_use_build doc-pdf LATEX)
	)

	cmake-utils_src_configure
}

src_compile() {
	local make_opts
	use doc && make_opts="all doc"
	cmake-utils_src_make ${make_opts}
}

src_install() {
	use doc && doman "${BUILD_DIR}"/doc/man/en/pgrouting.7
	use doc && dohtml -r "${BUILD_DIR}"/doc/html/*
	use doc-pdf && dodoc "${BUILD_DIR}"/doc/latex/en/*.pdf

	dodoc README* VERSION

	cmake-utils_src_install
}
