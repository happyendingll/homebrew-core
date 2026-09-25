class IkeScan < Formula
  desc "Discover and fingerprint IKE hosts"
  homepage "https://github.com/royhills/ike-scan"
  license "GPL-3.0-or-later" => { with: "openvpn-openssl-exception" }
  head "https://github.com/royhills/ike-scan.git", branch: "master"

  stable do
    url "https://github.com/royhills/ike-scan/archive/refs/tags/1.9.5.tar.gz"
    sha256 "5152bf06ac82d0cadffb93a010ffb6bca7efd35ea169ca7539cf2860ce2b263f"

    # Backport fix for implicit-int
    patch do
      url "https://github.com/royhills/ike-scan/commit/9949ce4bdf9f4bcb616b2a5d273708a7ea9ee93d.patch?full_index=1"
      sha256 "99e46df8b50e26982f0462d633cf3638f9b3ff2f65b7b4588241f17628e0f9d7"
      type :backport
      resolves "https://github.com/royhills/ike-scan/pull/39"
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "d8ab5a50a53371af39b1c5153625666459209fba80e98c3769ecc359f45031ef"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "openssl@4"

  deny_network_access!

  def install
    # The bundled `getopt.h` declares `getopt()` without a prototype, which C23 reads as taking no arguments
    ENV["ac_cv_prog_cc_c23"] = "no"
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--mandir=#{man}",
                          "--with-openssl=#{formula_opt_prefix("openssl@4")}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    # We probably shouldn't probe any host for VPN servers, so let's keep this simple.
    system bin/"ike-scan", "--version"
  end
end
