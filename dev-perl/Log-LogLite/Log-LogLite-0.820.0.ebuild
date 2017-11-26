# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DIST_AUTHOR="RANI"
DIST_VERSION="0.82"

inherit perl-module

DESCRIPTION="Helps create simple logs for applications"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-perl/IO-LockedFile"
DEPEND="${RDEPEND}"
