class Augeas < Formula
  desc "Configuration editing tool and API"
  homepage "https://augeas.net/"
  url "https://github.com/hercules-team/augeas/releases/download/release-1.15.0/augeas-1.15.0.tar.gz"
  sha256 "95b2b5c4c10c964024c694d6349024e8033dcfa1aaba88884ea09394908d30ff"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
    regex(/\D*?(\d+(?:\.\d+)+)/i)
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "dc64c9957066526ea71c9832bb0e01ad70b6a5cd0c899b85183b37daf5e07b64"
  end

  head do
    url "https://github.com/hercules-team/augeas.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "readline"

  uses_from_macos "libxml2"

  deny_network_access!

  def install
    ENV.append "LDFLAGS", "-L#{formula_opt_lib("readline")}"

    configure = build.head? ? "./autogen.sh" : "./configure"
    system configure, *std_configure_args
    system "make", "install"
  end

  def caveats
    <<~EOS
      Lenses have been installed to:
        #{HOMEBREW_PREFIX}/share/augeas/lenses/dist
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/augtool --version 2>&1")

    (testpath/"etc/hosts").write <<~EOS
      192.168.0.1 brew.sh test
    EOS

    assert_equal <<~EOS, shell_output("#{bin}/augtool --root #{testpath} 'print /files/etc/hosts/1'")
      /files/etc/hosts/1
      /files/etc/hosts/1/ipaddr = "192.168.0.1"
      /files/etc/hosts/1/canonical = "brew.sh"
      /files/etc/hosts/1/alias = "test"
    EOS

    assert_equal <<~EOS, shell_output("#{bin}/augprint --lens=hosts --target=/etc/hosts #{testpath}/etc/hosts")
      setm /augeas/load/*[incl='/etc/hosts' and label() != 'hosts']/excl '/etc/hosts'
      transform hosts incl /etc/hosts
      load-file /etc/hosts
      set /files/etc/hosts/seq::*[ipaddr='192.168.0.1']/ipaddr '192.168.0.1'
      set /files/etc/hosts/seq::*[ipaddr='192.168.0.1']/canonical 'brew.sh'
      set /files/etc/hosts/seq::*[ipaddr='192.168.0.1']/alias 'test'
    EOS
  end
end
