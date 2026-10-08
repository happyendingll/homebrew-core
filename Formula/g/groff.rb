class Groff < Formula
  desc "GNU troff text-formatting system"
  homepage "https://www.gnu.org/software/groff/"
  url "https://ftpmirror.gnu.org/groff/groff-1.24.2.tar.gz"
  mirror "https://ftp.gnu.org/gnu/groff/groff-1.24.2.tar.gz"
  sha256 "f9c1efd5bebbe37fc6e1063db7473ce8df1e3e0be4ff0f43ce04fce57e9c5dd9"
  license "GPL-3.0-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "231ac54076447d1744746c2ae862d364216cc625f5fb36fffefc983548b1a01a"
  end

  depends_on "pkgconf" => :build
  depends_on "ghostscript"
  depends_on "netpbm"
  depends_on "psutils"
  depends_on "uchardet"

  uses_from_macos "bison" => :build
  uses_from_macos "perl"

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  on_linux do
    depends_on "glib"
  end

  deny_network_access!

  def install
    # Local config needs to survive upgrades
    inreplace "Makefile.in" do |s|
      s.change_make_var! "localfontdir", "@sysconfdir@/groff/site-font"
      s.change_make_var! "localtmacdir", "@sysconfdir@/groff/site-tmac"
    end
    # Upstream still uses K&R function definitions, which do not compile as C23.
    ENV["ac_cv_prog_cc_c23"] = "no"
    system "./configure", "--sysconfdir=#{etc}",
                          "--without-x",
                          "--with-uchardet",
                          *std_configure_args
    system "make" # Separate steps required
    system "make", "install"
  end

  test do
    assert_match "homebrew\n", pipe_output("#{bin}/groff -a", "homebrew\n")
  end
end
