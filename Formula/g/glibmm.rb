class Glibmm < Formula
  desc "C++ interface to glib"
  homepage "https://gtkmm.gnome.org/"
  url "https://download.gnome.org/sources/glibmm/2.90/glibmm-2.90.0.tar.xz"
  sha256 "e2efa45643f16b9fea2d6299f2f403d672eaeacddf0ff7f8094e1af9b0f5980b"
  license "LGPL-2.1-or-later"
  compatibility_version 1

  # See `glib` livecheck
  livecheck do
    url :stable
    regex(/glibmm-(\d+(?:\.\d+)*)\.t/i)
    strategy :gnome do |page, regex|
      page.scan(regex).select { |match| Version.new(match.first).minor.to_i.even? }.flatten
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "38c1091cd921f971ba34c55a6b8f2d5fb475717c8f0c24274d22473923cea014"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "glib"
  depends_on "libsigc++"

  def install
    system "meson", "setup", "build", "-Dbuild-examples=false", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <glibmm.h>

      int main(int argc, char *argv[])
      {
         Glib::ustring my_string("testing");
         return 0;
      }
    CPP
    flags = shell_output("pkgconf --cflags --libs glibmm-2.68").chomp.split
    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
