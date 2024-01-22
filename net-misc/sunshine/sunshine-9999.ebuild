# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 desktop udev systemd #fcaps

DESCRIPTION="Self-hosted game stream host for Moonlight"
HOMEPAGE="https://app.lizardbyte.dev/Sunshine/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/LizardByte/Sunshine.git"
EGIT_BRANCH="nightly"

FEATURES="-network-sandbox"

# Licenses (may be incomplete)
#-----------------------------
# Sunshine: GPL3
# 	Simple Web Server: MIT
# 	TPCircularBuffer: BSD 3-Clause
# 	ViGEmClient: unlicensed?
# 	ffmpeg: LGPL2.1+
# 	miniupnp: BSD 3-Clause
# 	moonlight-common-c: GPL3
# 		enet: MIT
# 	nanors: MIT
# 	tray: MIT
# 	wayland-protocols: MIT
# 	wlr-protocols: unlicensed?
LICENSE="GPL-3 MIT LGPL-2.1+ BSD"
SLOT="0"
KEYWORDS=""
IUSE="nvenc cuda wayland X libdrm systemd"
REQUIRED_USE="
	nvenc? ( cuda )
	|| ( wayland X )
"

DEPEND="
	net-dns/avahi
	dev-libs/libinput
	dev-libs/boost
	net-misc/curl
	dev-libs/libayatana-appindicator
	dev-libs/libevdev
	media-libs/intel-mediasdk
	x11-libs/libnotify
	media-libs/libpulse
	media-libs/libva
	x11-libs/libvdpau
	X? (
		x11-libs/libX11
		x11-libs/libxcb
		x11-libs/libXfixes
		x11-libs/libXrandr
		x11-libs/libXtst
	)
	sys-process/numactl
	dev-libs/openssl
	media-libs/opus
	virtual/udev
	sys-libs/libcap
	libdrm? (
		x11-libs/libdrm
	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	virtual/pkgconfig
	net-libs/nodejs
"

PATCHES=(
	"${FILESDIR}"/sunshine-remove-systemd-install.patch
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DSUNSHINE_EXECUTABLE_PATH=/usr/bin/sunshine
		-DSUNSHINE_ASSETS_DIR="share/sunshine"
	)
	if use cuda; then
		mycmakeargs+=(-DSUNSHINE_ENABLE_CUDA=ON)
	fi
	if use libdrm; then
		mycmakeargs+=(-DSUNSHINE_ENABLE_DRM=ON)
	fi
	if use wayland; then
		mycmakeargs+=(-DSUNSHINE_ENABLE_WAYLAND=ON)
	fi
	if use X; then
		mycmakeargs+=(-DSUNSHINE_ENABLE_X11=ON)
	fi
	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/sunshine"
	insinto "${EPREFIX}/usr/share/sunshine/web/images"
	doins -r "${BUILD_DIR}/assets/web/images/"*

	insinto "${EPREFIX}/usr/share/sunshine/web/assets"
	doins -r "${BUILD_DIR}/assets/web/assets/"*

	insinto "${EPREFIX}/usr/share/sunshine/web"
	doins -r "${BUILD_DIR}/assets/web/"*

	insinto "${EPREFIX}/usr/share/sunshine/shaders/opengl"
	doins -r "${WORKDIR}/${P}/src_assets/linux/assets/shaders/opengl/"*

	insinto "${EPREFIX}/usr/share/sunshine"
	doins -r "${WORKDIR}/${P}/src_assets/common/assets/"*
	doins -r "${WORKDIR}/${P}/src_assets/linux/assets/"*
	doins -r "${BUILD_DIR}/assets/"*

	newicon -s 256 "${WORKDIR}/${P}/sunshine.png" sunshine.png
	newicon -s scalable "${WORKDIR}/${P}/sunshine.svg" sunshine.svg
	domenu "${BUILD_DIR}"/sunshine.desktop

	udev_dorules "${FILESDIR}"/85-sunshine.rules
	systemd_dounit "${FILESDIR}"/sunshine.service
	#fcaps cap_sys_admin+p "${BUILD_DIR}/sunshine"
}

pkg_postinst() {
	udev_reload
	xdg_icon_cache_update

	einfo "If you get \"Error: Failed to gain CAP_SYS_ADMIN\", run \`setcap cap_sys_admin+p \$(readlink -f \$(which sunshine))\` as root"
}

pkg_postrm() {
	udev_reload
	xdg_icon_cache_update
}
