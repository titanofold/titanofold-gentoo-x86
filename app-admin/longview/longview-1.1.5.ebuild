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
IUSE="apache2 mysql nginx"

RDEPEND="
	app-portage/eix
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

pkg_postinst() {
	local api_key
	local api_key_path=/etc/linode/longview.key

	[[ -f ${api_key_path} ]] && api_key=$(<${api_key_path})

	if [[ -z $api_key ]] ; then
		elog "Before you start Longview, you need to get the API key for this host."
		elog "Go to:"
		elog "    https://manager.linode.com/longview/"
		elog "Click on the 'i' button of the client matching this host (or create a"
		elog "new one), and save the Longview API Key to:"
		elog "    ${api_key_path}"
		elog
	fi

	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		if use apache2 ; then
			elog "You'll need to configure Apache as detailed in the following link:"
			elog "https://www.linode.com/docs/platform/longview/longview-app-for-apache#manual-configuration-all-distributions"
			elog
		fi

		elog "You'll need to open the firewall a bit so Longview client can talk with"
		elog "the monitoring server:"
		elog
		elog "    # iptables -I INPUT -s longview.linode.com -j ACCEPT"
		elog "    # iptables -I OUTPUT -d longview.linode.com -j ACCEPT"
		elog "    # ip6tables -I INPUT -s longview.linode.com -j ACCEPT"
		elog "    # ip6tables -I OUTPUT -d longview.linode.com -j ACCEPT"
		elog
		elog "    # rc-service iptables save"
		elog "    # rc-service ip6tables save"
		elog

		elog "Once you've done the above, you can start it:"
		elog "    # rc-service longview start"
		elog "    # rc-update add longview"
	fi
}
