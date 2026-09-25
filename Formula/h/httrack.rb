class Httrack < Formula
  desc "Website copier/offline browser"
  homepage "https://www.httrack.com/"
  url "https://github.com/xroche/httrack/releases/download/3.50.4/httrack-3.50.4.tar.gz"
  sha256 "f97dbb96d110681b4349912c8bc5c4011a6c227a7d4294ea1d4f0093baea51b6"
  license "GPL-3.0-or-later" => { with: "openvpn-openssl-exception" }

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "450362c49d28a79def4976220225cb81d99a64a8ad1d6e84afc601341e6a1ff5"
  end

  depends_on "openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  allow_network_access! :test

  def install
    ENV.deparallelize
    ENV.append "LDFLAGS", "-Wl,-rpath,#{lib}" if OS.mac?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
    # Gnome integration is inert on macOS, but Linux desktops use it
    rm_r(Dir["#{share}/{applications,pixmaps,icons,metainfo}"]) if OS.mac?
  end

  test do
    download = "https://raw.githubusercontent.com/Homebrew/homebrew/65c59dedea31/.yardopts"
    system bin/"httrack", download, "-O", testpath
    assert_path_exists testpath/"raw.githubusercontent.com"
  end
end
