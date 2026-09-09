# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/rootless-containers/rootlesskit.git"
inherit git-r3 go-module

DESCRIPTION="Linux-native \"fake root\" for implementing rootless containers"
HOMEPAGE="https://github.com/rootless-containers/rootlesskit"

LICENSE="Apache-2.0"
LICENSE+=" BSD BSD-2 ISC MIT"
SLOT="0"

KEYWORDS=""
IUSE="selinux"

RDEPEND="selinux? ( sec-policy/selinux-rootlesskit )"

RESTRICT="mirror network-sandbox"

src_unpack() {
  git-r3_src_unpack
}

src_install() {
  local -x BINDIR=${EPREFIX}/usr/bin
  default
}
