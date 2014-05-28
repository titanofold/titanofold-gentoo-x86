# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime/DateTime-1.030.0.ebuild,v 1.11 2014/04/29 15:00:43 zlogene Exp $

EAPI=5

MODULE_AUTHOR=STRUAN
MODULE_VERSION=0.14
inherit perl-module

DESCRIPTION="HTML to text conversion with links as footnotes"

LICENSE="Artistic-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND=""
DEPEND="${RDEPEND}
	>=dev-perl/HTML-Format-2
	dev-perl/HTML-Tree
	dev-perl/URI
	test? ( virtual/perl-Test-Simple )
"

SRC_TEST="do"
