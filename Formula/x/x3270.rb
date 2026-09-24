class X3270 < Formula
  desc "IBM 3270 terminal emulator for the X Window System and Windows"
  homepage "https://x3270.bgp.nu/"
  url "https://downloads.sourceforge.net/project/x3270/x3270/4.5ga6/suite3270-4.5ga6-src.tgz"
  sha256 "06faf5ce883852258cc6a2a4da9fe5ce023e97d01e50625ff36f4a01ea703468"
  license "BSD-3-Clause"

  livecheck do
    url "https://x3270.miraheze.org/wiki/Downloads"
    regex(/href=.*?suite3270[._-]v?(\d+(?:\.\d+)+(?:ga\d+)?)(?:-src)?\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "589450ab783bce07ee04af2fdc10d90d9a4fdd38d2ca5ee7ed6560f06a7482ce"
  end

  depends_on "openssl@4"
  depends_on "readline"

  uses_from_macos "python" => :build
  uses_from_macos "expat"
  uses_from_macos "ncurses"

  on_linux do
    depends_on "bdftopcf" => :build
    depends_on "mkfontscale" => :build
    depends_on "libx11"
    depends_on "libxaw"
    depends_on "libxmu"
    depends_on "libxt"
  end

  deny_network_access!

  def install
    args = %w[
      --enable-c3270
      --enable-pr3287
      --enable-s3270
    ]
    args += if OS.mac?
      %w[--disable-x3270 --enable-tcl3270]
    else
      %w[--enable-x3270 --disable-tcl3270]
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install.man"
  end

  test do
    system bin/"c3270", "--version"
  end
end
