# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PLOCALES=(
ar ca-ES cs-CZ da de-DE el en-GB en-US es-AR es-ES et-EE eu-ES fi-FI fr-FR he-IL
hu-HU id-ID it-IT ja-JP ko-KR lt lv-LV nb-NO nl-NL pl-PL pt-BR pt-PT ro-RO ru-RU
sk sv-SE tr-TR vi zh-CN
)

CMAKE_MAKEFILE_GENERATOR=ninja

inherit cmake-utils

DESCRIPTION="Fast and usable calculator for power users"
HOMEPAGE="http://speedcrunch.org/"
SRC_URI="https://bitbucket.org/heldercorreia/${PN}/get/release-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc ${PLOCALES[@]/#/l10n_}"

DEPEND="
dev-qt/qtcore:5
dev-qt/qthelp:5
dev-qt/qtsql:5
dev-qt/qtwidgets:5
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/heldercorreia-speedcrunch-ea93b21f9498/src"

src_prepare() {
	my_rm_loc() {
		rm "resources/locale/${1}.qm" || die
		sed -i resources/speedcrunch.qrc \
			-e "s|<file>locale/${1}.qm</file>||" || die
	}

	local i
	for i in "${PLOCALES[@]}" ; do
		use l10n_${i} || my_rm_loc ${i}
	done

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install
	cd .. || die
	doicon -s scalable gfx/speedcrunch.svg
	use doc && dodoc doc/*.pdf
}
