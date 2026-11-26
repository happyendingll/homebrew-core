class Fetchmail < Formula
  desc "Client for fetching mail from POP, IMAP, ETRN or ODMR-capable servers"
  homepage "https://www.fetchmail.info/"
  url "https://downloads.sourceforge.net/project/fetchmail/branch_6.6/fetchmail-6.6.10.tar.xz"
  sha256 "f32f1ecfdb99a243b6f7fef5d1b5f5aeac2bb0a45ce0162552d6063db3b48073"
  license all_of: [
    "LGPL-2.1-or-later",
    "ISC",
    "BSD-3-Clause",
    :public_domain,
    "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" },
  ]

  livecheck do
    url :stable
    regex(%r{url=.*?/branch_\d+(?:\.\d+)*?/fetchmail[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 sequoia: "62919133f76c4f4c43d9c1ce1b040006218d8e849a93631660f5ab2c14501b8b"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  deny_network_access!

  def install
    openssl_prefix = dep("openssl").opt_prefix
    system "./configure", "--with-ssl=#{openssl_prefix}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"fetchmail", "--version"
  end
end
