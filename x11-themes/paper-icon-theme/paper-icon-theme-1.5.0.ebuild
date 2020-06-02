# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson xdg

DESCRIPTION="Paper icon and cursor theme for X.Org"
HOMEPAGE="https://snwh.org/paper"

if [[ ${PV} = "9999" ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/snwh/paper-icon-theme.git"
	inherit git-r3
else
	SRC_URI="https://github.com/snwh/${PN}/archive/v.${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="CC-BY-SA-4.0"
SLOT="0"

S="${WORKDIR}/${PN}-v.${PV}"

src_install() {
	meson_src_install

	dodir usr/share/cursors/Paper
	mv "${ED}"/usr/share/icons/Paper/cursors "${ED}"/usr/share/cursors/Paper \
		|| die "Couldn't mv cursors"
	mv "${ED}"/usr/share/icons/Paper/cursor.theme \
	   "${ED}"/usr/share/cursors/Paper/ \
		|| die "Couldn't mv cursor.theme"
}
