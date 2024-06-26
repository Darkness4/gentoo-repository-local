# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib flag-o-matic

DESCRIPTION="Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder)"
HOMEPAGE="https://github.com/gianni-rosato/svt-av1-psy"

_PV="${PV/_rc/-rc}"

if [[ ${PV} = 9999 ]]; then
  inherit git-r3
  EGIT_REPO_URI="https://github.com/gianni-rosato/svt-av1-psy.git"
else
  SRC_URI="https://github.com/gianni-rosato/svt-av1-psy/archive/refs/tags/v${_PV}-A.tar.gz -> ${P}-A.tar.gz"
  KEYWORDS="amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv sparc x86"
  S="${WORKDIR}/svt-av1-psy-${_PV}-A"
fi

# Also see "Alliance for Open Media Patent License 1.0"
LICENSE="BSD-2 Apache-2.0 BSD ISC LGPL-2.1+ MIT"
SLOT="0"

BDEPEND="amd64? ( dev-lang/yasm )"

multilib_src_configure() {
  append-ldflags -Wl,-z,noexecstack

  local mycmakeargs=(
    # Tests require linking against https://github.com/Cidana-Developers/aom/tree/av1-normative ?
    # undefined reference to `ifd_inspect'
    # https://github.com/Cidana-Developers/aom/commit/cfc5c9e95bcb48a5a41ca7908b44df34ea1313c0
    -DBUILD_TESTING=OFF
    -DCMAKE_OUTPUT_DIRECTORY="${BUILD_DIR}"
  )

  [[ ${ABI} != amd64 ]] && mycmakeargs+=(-DCOMPILE_C_ONLY=ON)

  cmake_src_configure
}
