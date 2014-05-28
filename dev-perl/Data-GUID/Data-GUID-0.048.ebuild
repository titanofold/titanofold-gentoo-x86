# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime/DateTime-1.030.0.ebuild,v 1.11 2014/04/29 15:00:43 zlogene Exp $

EAPI=5

MODULE_AUTHOR=RJBS
MODULE_VERSION=0.048
inherit perl-module

DESCRIPTION="Simple interface for generating and using globally unique identifiers"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND="
	>=dev-perl/Data-UUID-1.148
	>=dev-perl/Sub-Exporter-0.90
	>=dev-perl/Sub-Install-0.03
"
DEPEND="${RDEPEND}
	test? ( >=virtual/perl-Test-Simple-0.96 )
"

SRC_TEST="do"
