class Groff < Formula
  desc "GNU troff text-formatting system"
  homepage "https://www.gnu.org/software/groff/"
  url "https://ftpmirror.gnu.org/groff/groff-1.25.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/groff/groff-1.25.0.tar.gz"
  sha256 "24d103a07eb79e418963bce206c8771b649871f83bda2fd4c2e65529c1c56921"
  license "GPL-3.0-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "8eb359d794bfdf0498a9d56be29a950ff93fa86afa52db16117222d4820b4cb8"
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
