class Fetchmail < Formula
  desc "Client for fetching mail from POP, IMAP, ETRN or ODMR-capable servers"
  homepage "https://www.fetchmail.info/"
  url "https://downloads.sourceforge.net/project/fetchmail/branch_6.6/fetchmail-6.6.8.tar.xz"
  sha256 "fff279d7ffbf4d9449110f715c0deb5ff5a2b13b317914b6f2c810ea12a0b7e1"
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
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "024a24ee3b1a21b66bc5fd19bf5046789a4d2dd608659a9bc9a042f569fe51a8"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-ssl=#{formula_opt_prefix("openssl@3")}"
    system "make", "install"
  end

  test do
    system bin/"fetchmail", "--version"
  end
end
