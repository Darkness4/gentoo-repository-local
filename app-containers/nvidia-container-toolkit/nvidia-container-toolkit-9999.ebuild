# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGO_PN="github.com/NVIDIA/${PN}"

inherit go-module

DESCRIPTION="NVIDIA container runtime toolkit"
HOMEPAGE="https://github.com/NVIDIA/nvidia-container-toolkit"

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/NVIDIA/${PN}.git"
	inherit git-r3

	src_unpack() {
		git-r3_src_unpack

		[[ -d "${S}"/vendor ]] && rm -rf "${S}"/vendor
		go-module_live_vendor
	}
else
	SRC_URI="
		https://github.com/NVIDIA/${PN}/archive/v${PV/_rc/-rc.}.tar.gz -> ${P}.tar.gz
	"
	S="${WORKDIR}/${PN}-${PV/_rc/-rc.}"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"

IUSE="hook operator-extensions"

RDEPEND="
	sys-libs/libnvidia-container
"

DEPEND="${RDEPEND}"

BDEPEND="
	app-arch/unzip
	dev-build/make
"

src_compile() {
	sed -i 's/^\(EXTLDFLAGS\s*=\s*\)\(.*\)/\1\2 -Wl,-z,lazy/' Makefile
	emake binaries
}

src_install() {
	dobin "nvidia-ctk"
	dobin "nvidia-container-runtime"
	if use operator-extensions; then
		dobin "nvidia-container-runtime.cdi"
		dobin "nvidia-container-runtime.legacy"
	fi

	./nvidia-ctk --quiet config --in-place --config="${EPREFIX}/etc/nvidia-container-runtime/config.toml" || die

	if use hook; then
		dobin "nvidia-container-runtime-hook"

		insinto "/usr/libexec/oci/hooks.d"
		doins "oci-nvidia-hook"

		insinto "/usr/share/containers/oci/hooks.d"
		doins "oci-nvidia-hook.json"
	fi
}

pkg_postinst() {
	elog "Your docker service must restart after install this package."
	elog "OpenRC: sudo rc-service docker restart"
	elog "systemd: sudo systemctl restart docker"
	elog "You may need to edit your /etc/nvidia-container-runtime/config.toml"
	elog "file before running ${PN} for the first time."
	elog "For details, please see the NVIDIA docker manual page."
}
