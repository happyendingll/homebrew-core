class Paps < Formula
  desc "Pango to PostScript converter"
  homepage "https://github.com/dov/paps"
  url "https://github.com/dov/paps/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "603bab59a49a8dd76b2a025919a705d21d44c8e929c72c6ed5e7ad0e87fbc486"
  license "LGPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "6a9181b65f051dde33a93138bbb339efe9cc5044882f69056ce007bb54b2d631"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "cairo"
  depends_on "fmt"
  depends_on "glib"
  depends_on "libpaper"
  depends_on "pango"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
    pkgshare.install "examples"
  end

  test do
    system bin/"paps", pkgshare/"examples/small-hello.utf8", "--encoding=UTF-8", "-o", "paps.ps"
    assert_path_exists testpath/"paps.ps"
    assert_match "%!PS-Adobe-3.0", (testpath/"paps.ps").read
  end
end
