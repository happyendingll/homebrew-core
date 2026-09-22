class Libdex < Formula
  desc "Future-based programming for GLib-based applications"
  homepage "https://gitlab.gnome.org/GNOME/libdex"
  url "https://gitlab.gnome.org/GNOME/libdex/-/archive/1.2.0/libdex-1.2.0.tar.gz"
  sha256 "0feb7f0f76938500800c28e32e5a655ab95bf042263639c5cc0f79446f15401d"
  license "LGPL-2.1-or-later"
  head "https://gitlab.gnome.org/GNOME/libdex.git", branch: "main"

  # We restrict matching to versions with an even-numbered minor version number,
  # as an odd-numbered minor version number indicates a development version:
  # https://gitlab.gnome.org/GNOME/libdex/-/issues/22#note_2368290
  livecheck do
    url :stable
    regex(/^v?(\d+\.\d*[02468](?:\.\d+)*)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "df8287edd92ab64b7b9eb1b5443070b7aeed4003e54d325ae72ce059224c8c98"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "vala" => :build # for vapigen
  depends_on "glib"

  def install
    args = %w[
      -Dexamples=false
      -Dtests=false
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
    pkgshare.install "examples", "build/config.h"
  end

  test do
    cp %w[examples/cp.c config.h].map { |file| pkgshare/file }, "."

    ENV.append_to_cflags "-I."
    ENV.append_to_cflags shell_output("pkgconf --cflags libdex-1").chomp
    ENV.append "LDFLAGS", shell_output("pkgconf --libs-only-L libdex-1").chomp
    ENV.append "LDLIBS", shell_output("pkgconf --libs-only-l libdex-1").chomp

    system "make", "cp"

    text = Random.rand.to_s
    (testpath/"test").write text
    system "./cp", "test", "not-test"
    assert_equal text, (testpath/"not-test").read
  end
end
