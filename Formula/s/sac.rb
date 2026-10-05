class Sac < Formula
  desc "Seismic Analysis Code, Community Edition"
  homepage "https://github.com/EarthScope/sac-community"
  url "https://github.com/EarthScope/sac-community/archive/refs/tags/v103.0.tar.gz"
  sha256 "f61fbe30d0411fe3033bdb76731062da24940c27920338d0f91a867842b791b8"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "3766603f187e621a120eaa22da3c60f08496076c597a1efb31abc878a7eb709d"
  end

  depends_on "pkgconf" => :build
  depends_on "libx11"
  depends_on "libxpm"

  uses_from_macos "curl"
  uses_from_macos "libxml2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    # configure does not search the Homebrew prefix for X11
    system "./configure", "--x-includes=#{formula_opt_include("libx11")}",
                          "--x-libraries=#{formula_opt_lib("libx11")}",
                          *std_configure_args
    system "make"
    system "make", "install"

    # The environment scripts are sourced, not executed
    pkgshare.install bin/"sacinit.sh", bin/"sacinit.csh"
    rm lib/"README_lib"
  end

  def caveats
    <<~EOS
      Configuration scripts live in: #{opt_pkgshare}
    EOS
  end

  test do
    (testpath/"commands.m").write <<~EOS
      fg impulse npts 100 delta 0.01
      w test.sac
      quit
    EOS

    system bin/"sac", "commands.m"
    assert_equal %w[test.sac 0.01 100], shell_output("#{bin}/saclst delta npts f test.sac").split
  end
end
