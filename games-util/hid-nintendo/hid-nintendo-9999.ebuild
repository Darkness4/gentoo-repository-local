EAPI=7

inherit git-r3 linux-mod

DESCRIPTION="A Nintendo HID kernel module"
HOMEPAGE="https://github.com/nicman23/dkms-hid-nintendo https://github.com/DanielOgorchock/linux"
EGIT_REPO_URI="https://github.com/nicman23/dkms-hid-nintendo"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

MODULE_NAMES="${PN}(kernel/drivers/hid:${S}/src)"
BUILD_TARGETS="-C /usr/src/linux M=${S}/src"

pkg_setup() {
  CONFIG_CHECK="~HID ~HID_GENERIC ~USB_HID ~HIDRAW ~UHID"
  check_extra_config
  linux-mod_pkg_setup
}
