# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd

DESCRIPTION="Linode's Longview Agent"
HOMEPAGE="https://github.com/linode/longview"
SRC_URI="https://github.com/linode/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="apache2 mysql nginx systemd"

RDEPEND="
	dev-lang/perl
	dev-perl/Crypt-SSLeay
	dev-perl/DBI
	dev-perl/IO-Socket-INET6
	dev-perl/JSON
	dev-perl/Linux-Distribution
	dev-perl/Log-LogLite
	dev-perl/perl-headers
	dev-perl/Try-Tiny
	apache2? ( www-servers/apache[apache2_modules_status] )
	mysql? ( dev-perl/DBD-mysql )
	systemd? ( sys-apps/systemd )
"

src_prepare() {
	sed 's|/var/run|/run|' \
		-i Linode/Longview/Util.pm \
		-i Extras/init/longview.service \
		|| die "sed failed"

	eapply_user
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	default

	insinto /opt/linode/${PN}
	doins -r Linode

	fperms 0755 /opt/linode/longview/Linode/Longview.pl

	insinto /opt/linode/${PN}/Linode/Longview/DataGetter/Packages/
	doins Extras/Modules/Packages/Gentoo.pm

	keepdir /var/log/linode/

	insinto /etc/linode/longview.d/
	keepdir /etc/linode/longview.d/
	use apache2 && doins Extras/conf/Apache.conf
	use mysql   && doins Extras/conf/MySQL.conf
	use nginx   && doins Extras/conf/Nginx.conf

	doinitd "${FILESDIR}"/${PN}
	systemd_dounit Extras/init/longview.service
}
