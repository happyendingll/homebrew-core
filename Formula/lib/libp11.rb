class Libp11 < Formula
  desc "PKCS#11 wrapper library in C"
  homepage "https://github.com/OpenSC/libp11/wiki"
  url "https://github.com/OpenSC/libp11/releases/download/libp11-0.4.21/libp11-0.4.21.tar.gz"
  sha256 "efdb523aef8613d447e6a2d38227d4b389866f4bcf4b503130acd7f759490847"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
    regex(/^libp11[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "0f359e7e07cfd87a339776d8e900acad4cf1b49291be41aa5acc0fc1be99ea96"
  end

  head do
    url "https://github.com/OpenSC/libp11.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "libtool"
  depends_on "openssl@4"

  deny_network_access!

  def install
    pkgconf_options = ["--define-variable=prefix=#{prefix}", "--variable=modulesdir"]
    modulesdir = Utils.safe_popen_read("pkgconf", *pkgconf_options, "libcrypto").chomp

    system "./bootstrap" if build.head?
    system "./configure", "--disable-silent-rules",
                          "--with-modulesdir=#{modulesdir}",
                          *std_configure_args
    system "make", "install"
    pkgshare.install "examples/auth.c"
  end

  test do
    openssl = "openssl@4"
    system ENV.cc, pkgshare/"auth.c", "-I#{formula_opt_include(openssl)}",
                   "-L#{lib}", "-L#{formula_opt_lib(openssl)}",
                   "-lp11", "-lcrypto", "-o", "test"
  end
end
