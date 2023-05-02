# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 cmake linux-info udev

DESCRIPTION="Daemon that uses hid-nintendo evdev devices to implement joycon pairing"
HOMEPAGE="https://github.com/DanielOgorchock/joycond"
EGIT_REPO_URI="https://github.com/DanielOgorchock/joycond"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/libevdev
	virtual/udev
"

RDEPEND="
	${DEPEND}
"

CONFIG_CHECK="
	~HID
	~HID_NINTENDO
	~HIDRAW
"

src_install() {
  cmake_src_install
  newinitd "${FILESDIR}"/${PN}.initd ${PN}
  doman doc/${PN}.1
}

pkg_postinst() {
  udev_reload
}

pkg_postrm() {
  udev_reload
}
