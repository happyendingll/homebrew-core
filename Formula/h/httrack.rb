class Httrack < Formula
  desc "Website copier/offline browser"
  homepage "https://www.httrack.com/"
  url "https://github.com/xroche/httrack/releases/download/3.50.3/httrack-3.50.3.tar.gz"
  sha256 "644d4ec0e48ad596dacd7f8017b68d8a3f1dfc140284b412b53086e7d1664e9d"
  license "GPL-3.0-or-later" => { with: "openvpn-openssl-exception" }

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "f60a5fd42bc41c508bb11d5d4e3fc57f07f5f948325e462761bfd2124b394be3"
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
