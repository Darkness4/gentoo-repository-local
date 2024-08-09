# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

DESCRIPTION="Loading data into PostgreSQL"
HOMEPAGE="http://pgloader.io"
SRC_URI=""
inherit git-r3
EGIT_REPO_URI="https://github.com/dimitri/pgloader.git"
EGIT_COMMIT="v3.6.10"

RESTRICT="network-sandbox nostrip"

LICENSE=""
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="dev-lisp/sbcl dev-db/freetds dev-libs/libzip"
RDEPEND="${DEPEND}"

src_compile() {
  emake -j1
}

src_install() {
  ls -lah
  dobin ./build/bin/pgloader
}
