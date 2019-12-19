# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

POSTGRES_COMPAT=( 9.{4..6} {10..12} )
POSTGRES_USEDEP="server,threads"

inherit postgres-multi

IUSE="doc perl"

DESCRIPTION="A replication system for the PostgreSQL Database Management System"
HOMEPAGE="http://slony.info/"

# ${P}-docs.tar.bz2 contains man pages as well as additional documentation
MAJ_PV=$(ver_cut 1-2)
SRC_URI="http://main.slony.info/downloads/${MAJ_PV}/source/${P}.tar.bz2
		 http://main.slony.info/downloads/${MAJ_PV}/source/${P}-docs.tar.bz2"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND="${POSTGRES_DEP}
		perl? ( dev-perl/DBD-Pg )
"

RDEPEND=${DEPEND}

REQUIRE_USE="${POSTGRES_REQ_USE}"

src_configure() {
	local slot_bin_dir="/usr/$(get_libdir)/postgresql-@PG_SLOT@/bin"
	use perl && myconf=" --with-perltools=\"${slot_bin_dir}\""
	postgres-multi_foreach econf ${myconf} \
						   --with-pgconfigdir="${slot_bin_dir}" \
						   --with-slonybindir="${slot_bin_dir}"
}

src_install() {
	postgres-multi_foreach emake DESTDIR="${D}" install

	dodoc README SAMPLE TODO UPGRADING share/slon.conf-sample

	if use doc ; then
		cd "${S}"/doc/adminguide || die
		docinto adminguide
		dodoc *.{html,css,png}
	fi

	newinitd "${FILESDIR}"/slony1.init slony1
	newconfd "${FILESDIR}"/slony1.conf slony1
}

postgres_sym_update() {
	# Slony-I installs its executables into a directory that is
	# processed by the PostgreSQL eselect module. Call it here so that
	# the symlinks will be created.
	ebegin "Refreshing PostgreSQL $(postgresql-config show) symlinks"
	postgresql-config update
	eend $?
}

pkg_postinst() {
	postgres_sym_update
}

pkg_postrm() {
	postgres_sym_update
}
