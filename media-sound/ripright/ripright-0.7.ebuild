# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="RigRight is a minimal CD ripper for Linux modeled on autorip."
HOMEPAGE="http://www.mcternan.me.uk/ripright/"
SRC_URI="http://www.mcternan.me.uk/ripright/software/ripright-0.7.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="media-sound/cdparanoia
net-misc/curl
media-gfx/imagemagick
media-libs/flac
media-libs/libdiscid

"
RDEPEND="${DEPEND}"
