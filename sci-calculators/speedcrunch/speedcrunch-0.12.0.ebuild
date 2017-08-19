# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PLOCALES=(
ar ca_ES cs_CZ da de_DE el en_GB en_US es_AR es_ES et_EE eu_ES fi_FI fr_FR he_IL
hu_HU id_ID it_IT ja_JP ko_KR lt lv_LV nb_NO nl_NL pl_PL pt_BR pt_PT ro_RO ru_RU
sk sv_SE tr_TR vi zh_CN
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
dev-qt/qtgui:5
dev-qt/qthelp:5
dev-qt/qtnetwork:5
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
		sed -i gui/mainwindow.cpp \
			-e "s|map.insert(QString::fromUtf8(\".*, QLatin1String(\"${1}\"));||" || die
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
