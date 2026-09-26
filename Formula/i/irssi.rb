class Irssi < Formula
  desc "Modular IRC client"
  homepage "https://irssi.org/"
  url "https://github.com/irssi/irssi/releases/download/1.4.5/irssi-1.4.5.tar.xz"
  sha256 "72a951cb0ad622785a8962801f005a3a412736c7e7e3ce152f176287c52fe062"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }
  revision 3

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "316af1a09778701f05eda33ece7d2c386522b05e9579ea1f7599a9e578923141"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "openssl@4"
  depends_on "perl"

  uses_from_macos "ncurses"

  on_macos do
    depends_on "gettext"
  end

  deny_network_access!

  def install
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("openssl@4")/"pkgconfig"

    perl_vendorarch = Utils.safe_popen_read("perl", "-MConfig", "-e", "print $Config{vendorarch}")

    args = %W[
      -Dwith-proxy=yes
      -Dwith-perl=yes
      -Dwith-perl-lib=#{perl_vendorarch.sub(HOMEBREW_PREFIX, prefix)}
    ]

    # Add RPATH to Perl modules so Homebrew's audit can find libperl.so.
    # The modules are loaded by Perl (which already has libperl), so this
    # isn't strictly needed at runtime, but satisfies the linkage check.
    if OS.linux?
      perl_archlib = Utils.safe_popen_read("perl", "-MConfig", "-e", "print $Config{archlib}")
      ENV.append "LDFLAGS", "-Wl,-rpath,#{perl_archlib}/CORE"
    end

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    require "pty"

    assert_match version.to_s, shell_output("#{bin}/irssi --version")

    stdout, = PTY.spawn("#{bin}/irssi -c irc.freenode.net -n testbrew")
    assert_match "Terminal doesn't support cursor movement", stdout.readline

    # Verify the Perl module compiled successfully. Upstream treats Perl
    # build failures as non-fatal, so they can go unnoticed. To debug,
    # move this test into the install block to surface build warnings.
    system "perl", "-e", "use Irssi"
  end
end
