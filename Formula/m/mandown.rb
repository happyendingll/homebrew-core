class Mandown < Formula
  desc "Man-page inspired Markdown viewer"
  homepage "https://github.com/Titor8115/mandown"
  url "https://github.com/Titor8115/mandown/archive/refs/tags/v1.1.tar.gz"
  sha256 "870e3fa2bd6b8ad5d2259e7ef30a69d4faa87ef6cad7b2d8e34dc4944b651335"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8d52f1720a26cd004dc9112892350fd3bc93e6201596d5969993e51dcb518048"
  end

  depends_on "pkgconf" => :build
  depends_on "libconfig"
  depends_on "ncurses" # undeclared identifier 'BUTTON5_PRESSED' with macos
  uses_from_macos "libxml2"

  def install
    system "make", "install", "PREFIX=#{prefix}", "PKG_CONFIG=pkg-config"
  end

  test do
    (testpath/".config/mdn").mkpath # `mdn` may misbehave when its config directory is missing.
    (testpath/"test.md").write <<~MARKDOWN
      # Hi from readme file!
    MARKDOWN
    expected_output = <<~HTML
      <html><head><title>test.md(7)</title></head><body><h1>Hi from readme file!</h1>
      </body></html>
    HTML
    if OS.mac?
      system bin/"mdn", "-f", "test.md", "-o", "test"
    else
      require "pty"
      _, _, pid = PTY.spawn(bin/"mdn", "-f", "test.md", "-o", "test")
      Process.wait(pid)
    end
    assert_equal expected_output, File.read("test")
  end
end
