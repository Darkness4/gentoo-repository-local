# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop xdg

DESCRIPTION="Wii U emulator."
HOMEPAGE="https://cemu.info/ https://github.com/cemu-project/Cemu"
MY_PN="Cemu"

if [[ "${PV}" == "9999" ]]; then
  EGIT_REPO_URI="https://github.com/cemu-project/${MY_PN}.git"
  inherit git-r3

  src_unpack() {
    git-r3_src_unpack
  }
else
  SRC_URI="https://github.com/cemu-project/${MY_PN}/archive/${SHA}.tar.gz -> ${P}.tar.gz"
  S="${WORKDIR}/${MY_PN}-${SHA}"
  KEYWORDS="~amd64"
fi

LICENSE="MPL-2.0 ISC"
SLOT="0"

IUSE="+cubeb discord +sdl +vulkan +opengl wayland"

DEPEND="app-arch/zstd
  cubeb? ( media-libs/cubeb )
  dev-libs/boost
  dev-libs/glib
  >=dev-libs/libfmt-9.1.0:=
  dev-libs/libzip
  dev-libs/openssl
  dev-libs/pugixml
  dev-libs/rapidjson
  wayland? (
    dev-libs/wayland
  )
  dev-util/glslang
  opengl? (
    media-libs/libglvnd
  )
  media-libs/libsdl2[joystick,threads]
  net-misc/curl
  sys-libs/zlib
  vulkan? ( dev-util/vulkan-headers )
  x11-libs/gtk+:3[wayland?]
  x11-libs/libX11
  x11-libs/wxGTK:3.2-gtk3[opengl?]"
RDEPEND="${DEPEND}"
BDEPEND="media-libs/glm"

src_prepare() {
  cmake_src_prepare
}

src_configure() {
  local mycmakeargs=(
    -DBUILD_SHARED_LIBS=OFF
    -DENABLE_CUBEB=$(usex cubeb)
    -DENABLE_DISCORD_RPC=$(usex discord)
    -DENABLE_OPENGL=$(usex opengl)
    -DENABLE_SDL=$(usex sdl)
    -DENABLE_VCPKG=OFF
    -DENABLE_WAYLAND=$(usex wayland)
    -DENABLE_VULKAN=$(usex vulkan)
    -DENABLE_WXWIDGETS=ON
    -DPORTABLE=OFF
    -DwxWidgets_CONFIG_EXECUTABLE=/usr/$(get_libdir)/wx/config/gtk3-unicode-3.2-gtk3
    -Wno-dev
  )
  cmake_src_configure
}

src_install() {
  newbin "bin/${MY_PN}_relwithdebinfo" "$MY_PN"
  insinto "/usr/share/${PN}/gameProfiles"
  doins -r bin/gameProfiles/default/*
  insinto "/usr/share/${PN}"
  doins -r bin/resources bin/shaderCache
  einstalldocs
  newicon -s 128 src/resource/logo_icon.png "info.${PN}.${MY_PN}.png"
  domenu "dist/linux/info.${PN}.${MY_PN}.desktop"
}
