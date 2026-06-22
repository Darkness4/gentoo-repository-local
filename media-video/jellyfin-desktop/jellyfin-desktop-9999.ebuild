EAPI=8

inherit cargo desktop xdg

DESCRIPTION="Jellyfin Desktop Client (Rust + CEF + mpv)"
HOMEPAGE="
  https://jellyfin.org/
  https://github.com/jellyfin/${PN}
"

if [[ ${PV} == *9999* ]]; then
  EGIT_REPO_URI="https://github.com/jellyfin/${PN}.git"
  EGIT_SUBMODULES=()
  inherit git-r3
else
  SRC_URI="https://github.com/jellyfin/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
  KEYWORDS="~amd64"
  S="${WORKDIR}"/${PN}-${PV}
fi

LICENSE="MIT ASL-2.0"
SLOT="0"

IUSE="+mpv +wayland +X"

RDEPEND="
    X? (
      x11-libs/libX11
      x11-libs/libxcb
    )
    wayland? ( dev-libs/wayland )
    mpv? ( media-video/mpv )
    dev-libs/openssl
"

DEPEND="
    ${RDEPEND}
    dev-lang/rust
"

PATCHES=(
  "${FILESDIR}/${PN}-fix-hardcoded-libdir.patch"
)

src_unpack() {
  export CARGO_MANIFEST_PATH="src/Cargo.toml"
  if ! use mpv; then
    EGIT_SUBMODULES+=('mpv')
  fi

  if [[ "${PV}" == 9999 ]]; then
    git-r3_src_unpack
    OLD_S="${S}"
    S="${S}/src"
    cargo_live_src_unpack
    S="${OLD_S}"
  else
    cargo_src_unpack
  fi

  cd "${S}" || die
  cargo xtask fetch-cef || die
}

src_compile() {
  cd "${S}" || die
  cargo xtask build \
    --external-mpv /usr \
    --out build || die
}

src_install() {
  cd "${S}" || die
  local cefdir="/opt/${PN}"

  # Main binary + CEF shared libs (need to stay executable)
  exeinto "${cefdir}"
  doexe build/${PN}
  doexe build/libcef.so
  doexe build/libEGL.so
  doexe build/libGLESv2.so
  doexe build/libvk_swiftshader.so
  doexe build/libvulkan.so.1

  # CEF data/resource files
  insinto "${cefdir}"
  doins build/chrome_100_percent.pak
  doins build/chrome_200_percent.pak
  doins build/resources.pak
  doins build/icudtl.dat
  doins build/v8_context_snapshot.bin

  # Locale paks
  insinto "${cefdir}/locales"
  doins build/locales/*.pak

  dosym /opt/${PN}/${PN} /usr/bin/${PN}

  doicon -s scalable resources/linux/org.jellyfin.JellyfinDesktop.svg
  domenu resources/linux/org.jellyfin.JellyfinDesktop.desktop
}
