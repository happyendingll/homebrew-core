class Uftp < Formula
  desc "Secure, reliable, efficient multicast file transfer program"
  homepage "https://uftp-multicast.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/uftp-multicast/source-tar/uftp-5.0.4.tar.gz"
  sha256 "50df3f0e59ebd59ed1b9bc8af991a0187df14d928188ff5f62c3d65adcd113ab"
  license "GPL-3.0-or-later" => { with: "openvpn-openssl-exception" }

  livecheck do
    url :stable
    regex(%r{url=.*?/uftp[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8f8246689d2e6b7e621ba465ca9a7c550535acdc6f581d62d2e2a0f8dbaa9e7f"
  end

  depends_on "openssl@4"

  def install
    system "make", "OPENSSL=#{formula_opt_prefix("openssl@4")}", "DESTDIR=#{prefix}", "install"
    # the makefile installs into DESTDIR/usr/..., move everything up one and remove usr
    # the project maintainer was contacted via sourceforge on 12-Feb, he responded WONTFIX on 13-Feb
    prefix.install (prefix/"usr").children
    (prefix/"usr").unlink
  end

  service do
    run [opt_bin/"uftpd", "-d"]
    keep_alive true
    working_dir var
  end

  test do
    system bin/"uftp_keymgt"
  end
end
