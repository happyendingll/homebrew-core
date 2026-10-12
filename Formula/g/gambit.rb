class Gambit < Formula
  desc "Software tools for game theory"
  homepage "https://www.gambit-project.org/"
  url "https://github.com/gambitproject/gambit/releases/download/v16.7.0/gambit-16.7.0.tar.gz"
  sha256 "35a2d7df4f8181cb216ce9a2b10ca820724768d8c69787a608a4a2725a745278"
  license all_of: ["GPL-2.0-or-later", "Zlib"]
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "b17037a9fe7fd279407f80d7d9268af91085fbbd1c30fdcfbbb3d12eb33fa4b0"
  end

  depends_on "wxwidgets"

  def install
    wxwidgets = deps.find { |dep| dep.name.match?(/^wxwidgets(@\d+(\.\d+)*)?$/) }.to_formula
    wx_config = wxwidgets.opt_bin/"wx-config-#{wxwidgets.version.major_minor}"
    system "./configure", "--disable-silent-rules",
                          "--with-wx-config=#{wx_config}",
                          *std_configure_args
    system "make", "install"

    # Sanitise references to Homebrew shims
    rm Dir["contrib/**/Makefile*"]
    pkgshare.install "contrib"
  end

  test do
    system bin/"gambit-enumpure", pkgshare/"contrib/games/e04.efg"
    system bin/"gambit-enummixed", pkgshare/"contrib/games/e04.nfg"
    system bin/"gambit-gnm", pkgshare/"contrib/games/e04.nfg"
    system bin/"gambit-ipa", pkgshare/"contrib/games/e04.nfg"
    system bin/"gambit-lcp", pkgshare/"contrib/games/e04.efg"
    system bin/"gambit-lp", pkgshare/"contrib/games/2x2const.nfg"
    system bin/"gambit-liap", pkgshare/"contrib/games/e04.nfg"
    system bin/"gambit-simpdiv", pkgshare/"contrib/games/e04.nfg"
    system bin/"gambit-logit", pkgshare/"contrib/games/e04.efg"
    system bin/"gambit-convert", "-O", "html", pkgshare/"contrib/games/2x2.nfg"
  end
end
