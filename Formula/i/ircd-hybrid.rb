class IrcdHybrid < Formula
  desc "High-performance secure IRC server"
  homepage "https://www.ircd-hybrid.org/"
  url "https://downloads.sourceforge.net/project/ircd-hybrid/ircd-hybrid/ircd-hybrid-8.2.47/ircd-hybrid-8.2.47.tgz"
  sha256 "d5f253f6dd1a93e7183323f410b7e2269ba4392d3d00a0e7dc6248f6f9864ffe"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
    regex(%r{url=.*?/ircd-hybrid[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "36d20878e25384ebfb7f61e8d56e13efa9607ebaf6b80001900fcbb31186ac1c"
  end

  depends_on "jansson"
  depends_on "openssl@4"

  uses_from_macos "libxcrypt"

  conflicts_with "expect", because: "both install an `mkpasswd` binary"
  conflicts_with "ircd-irc2", because: "both install an `ircd` binary"

  # ircd-hybrid needs the .la files
  skip_clean :la

  def install
    ENV.deparallelize # build system trips over itself

    system "./configure", "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--with-tls=openssl",
                          *std_configure_args.reject { |s| s["--disable-debug"] }
    system "make", "install"
    etc.install "doc/reference.modules.conf" => "ircd.conf"
  end

  def caveats
    <<~EOS
      You'll more than likely need to edit the default settings in the config file:
        #{etc}/ircd.conf
    EOS
  end

  service do
    run opt_bin/"ircd"
    keep_alive false
    working_dir HOMEBREW_PREFIX
    error_log_path var/"ircd.log"
  end

  test do
    system bin/"ircd", "-version"
  end
end
