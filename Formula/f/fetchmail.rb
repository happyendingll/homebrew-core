class Fetchmail < Formula
  desc "Client for fetching mail from POP, IMAP, ETRN or ODMR-capable servers"
  homepage "https://www.fetchmail.info/"
  url "https://downloads.sourceforge.net/project/fetchmail/branch_6.6/fetchmail-6.6.9.tar.xz"
  sha256 "3dfc47192e76099b5614f2b2a42198cb41fa05d7ca9b5073e08c051e9be81435"
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
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 sequoia: "79f74b3c6f8317fa85637b9dfd45249c6af7007b6ed01ced727321dd05f8e90c"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"

  deny_network_access!

  def install
    system "./configure", "--with-ssl=#{formula_opt_prefix("openssl@4")}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"fetchmail", "--version"
  end
end
