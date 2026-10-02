class Httrack < Formula
  desc "Website copier/offline browser"
  homepage "https://www.httrack.com/"
  url "https://github.com/xroche/httrack/releases/download/3.50.5/httrack-3.50.5.tar.gz"
  sha256 "4a017e8311035ec02ee2947e14022a5f1291c86c7e67e98ee762c9486f0db39d"
  license "GPL-3.0-or-later" => { with: "openvpn-openssl-exception" }

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "b889b2b21fa5608af6c177f9346cbf87148e13c4c8ecf76fac6d7a12c4812081"
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
