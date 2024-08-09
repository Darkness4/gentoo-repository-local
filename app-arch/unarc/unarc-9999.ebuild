EAPI=8

inherit git-r3

DESCRIPTION="Unpacker for ArC archives"
HOMEPAGE="https://github.com/xredor/unarc"
EGIT_REPO_URI="https://github.com/xredor/unarc.git"

SLOT="0"
KEYWORDS="~amd64 ~x86"

src_install() {
  dobin unarc
}
