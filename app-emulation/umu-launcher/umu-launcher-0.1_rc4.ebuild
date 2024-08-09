EAPI=8

MY_PV="0.1-RC4"

inherit multilib-minimal

DESCRIPTION="Unified Linux Wine Game Launcher"
HOMEPAGE="https://github.com/Open-Wine-Components/umu-launcher"
SRC_URI="
  ${HOMEPAGE}/archive/refs/tags/${MY_PV}.tar.gz
  https://github.com/Plagman/reaper/archive/88a182199fb6b336e184f1659060e83e74ea3ac4.tar.gz
"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="GPL-3.0-only"
SLOT="0"
KEYWORDS="amd64 ~x86"

DEPEND="
        app-shells/bash
        dev-lang/python
        dev-libs/libgpg-error
        dev-libs/nss
        dev-util/desktop-file-utils
        gnome-extra/zenity
        media-libs/freetype
        media-libs/libglvnd
        media-libs/vulkan-loader
        media-plugins/alsa-plugins
        net-misc/curl
        sys-apps/dbus
        sys-apps/diffutils
        sys-apps/lsb-release
        sys-apps/usbutils
        sys-libs/libxcrypt[compat]
        sys-process/lsof
        x11-apps/xrandr
        x11-libs/gdk-pixbuf
        x11-libs/libX11
        x11-libs/libXScrnSaver
        x11-misc/xdg-user-dirs
        x11-themes/hicolor-icon-theme
"
RDEPEND="${DEPEND}"
BDEPEND="
        app-text/scdoc
        app-shells/bash
        dev-build/make
        dev-build/meson
"

src_unpack() {
  default
  rmdir "${S}/subprojects/reaper"
  mv "reaper-88a182199fb6b336e184f1659060e83e74ea3ac4" "${S}/subprojects/reaper" || die "Unable to copy reaper"
}

src_configure() {
  ./configure.sh --prefix="${EPREFIX}/usr" || die
}

src_compile() {
  emake
}

src_install() {
  emake DESTDIR="${D}" install
}
