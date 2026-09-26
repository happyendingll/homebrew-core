class GambitScheme < Formula
  desc "Implementation of the Scheme Language"
  homepage "https://gambitscheme.org/"
  url "https://github.com/gambit/gambit/archive/refs/tags/v4.9.8.tar.gz"
  sha256 "0ec19b755dbda6c540e9e60b7235d801f26f40c2f211ddfb729b756218bcc873"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "159945817be0987ad66d02a39e3630c87ba48060dc5de6af60ffd72c01631653"
  end

  depends_on "openssl@4"

  on_macos do
    depends_on "gcc"
  end

  conflicts_with "ghostscript", because: "both install `gsc` binary"
  conflicts_with "gerbil-scheme", because: "both install `gsc` binary"
  conflicts_with "scheme48", because: "both install `scheme-r5rs` binaries"

  # Clang is slower both for compiling and for running output binaries
  fails_with :clang

  deny_network_access!

  def install
    args = %W[
      --prefix=#{prefix}
      --docdir=#{doc}
      --infodir=#{info}
      --enable-single-host
      --enable-default-runtime-options=f8,-8,t8
      --enable-openssl
    ]

    system "./configure", *args

    # Fixed in gambit HEAD, but they haven't cut a release
    inreplace "config.status" do |s|
      s.gsub! %r{/usr/local/opt/openssl(@\d(\.\d)?)?}, formula_opt_prefix("openssl@4")
    end
    system "./config.status"

    system "make"
    ENV.deparallelize
    system "make", "install"

    # fix lisp file install location
    elisp.install share/"emacs/site-lisp/gambit.el"
  end

  test do
    assert_equal "0123456789", shell_output("#{bin}/gsi -e \"(for-each write '(0 1 2 3 4 5 6 7 8 9))\"")
  end
end
