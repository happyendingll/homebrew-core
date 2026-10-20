class Dillo < Formula
  desc "Fast and small graphical web browser"
  homepage "https://dillo-browser.org/"
  url "https://dillo-browser.org/release/3.3.0/dillo-3.3.0.tar.gz"
  sha256 "db1863261d5efbd27b090e430c88064082b891cea1edf7a14e234cca51754f60"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://dillo-browser.org/release/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "e6ad426a68f3bb7388ee1fcb66bfc4e4c005e8ad7f652cfeb514f74c7e981e1e"
  end

  head do
    url "https://git.dillo-browser.org/dillo/", using: :git, branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  # TODO: Switch to unversioned `fltk` when possible.
  # https://github.com/dillo-browser/dillo/issues/246
  depends_on "fltk@1.3"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "openssl@4"

  on_linux do
    depends_on "brotli"
    depends_on "libx11"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    if build.head?
      ENV["NOCONFIGURE"] = "1"
      system "./autogen.sh"
    end

    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    test_file = testpath/"test.html"
    (testpath/"test.html").write <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
            <title>BrewTest</title>
        </head>
        <body>
            <h1>test</h1>
        </body>
      </html>
    HTML

    # create bunch of dillo resource files
    (testpath/".dillo").mkpath
    (testpath/".dillo/dillorc").write ""
    (testpath/".dillo/keysrc").write ""
    (testpath/".dillo/domainrc").write ""
    (testpath/".dillo/hsts_preload").write ""

    begin
      PTY.spawn(bin/"dillo", test_file) do |_r, _w, pid|
        sleep 15
        Process.kill("TERM", pid)
      end
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    end

    assert_match "DEFAULT DENY", (testpath/".dillo/cookiesrc").read

    assert_match version.to_s, shell_output("#{bin}/dillo --version")
  end
end
