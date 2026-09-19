class Gom < Formula
  desc "GObject wrapper around SQLite"
  homepage "https://wiki.gnome.org/Projects/Gom"
  url "https://download.gnome.org/sources/gom/0.5/gom-0.5.6.tar.xz"
  sha256 "4d7a5e268698c8e7e40603e36e9e3a2b76133931ce1b637c1136301491b54cc3"
  license "LGPL-2.1-or-later"

  # We use a common regex because gom doesn't use GNOME's "even-numbered
  # minor is stable" version scheme.
  livecheck do
    url :stable
    regex(/gom[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "5f2f6dcc7055f77d9cf88906fb2f244f447b00bfcb70a28198c154c0a322c072"
  end

  depends_on "gdk-pixbuf" => :build # https://gitlab.gnome.org/GNOME/gom/-/issues/18
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "python@3.14" => :build
  depends_on "glib"
  depends_on "sqlite" # indirect dependency via glib

  # Help find `gdk-pixbuf` as superenv doesn't add dependencies of build dependencies
  def gdk_pixbuf_add_pkgconfig_paths!
    deps_set = Set.new
    Formula["gdk-pixbuf"].recursive_dependencies do |_, dep|
      next Dependable::PRUNE if !dep.required? || deps_set.include?(dep)

      deps_set << dep
      dep_f = dep.to_formula
      ENV.append_path "PKG_CONFIG_PATH", dep_f.opt_lib/"pkgconfig" if (dep_f.opt_lib/"pkgconfig").exist?
      ENV.append_path "PKG_CONFIG_PATH", dep_f.opt_share/"pkgconfig" if (dep_f.opt_share/"pkgconfig").exist?
    end
  end

  def install
    site_packages = prefix/Language::Python.site_packages(python3)
    gdk_pixbuf_add_pkgconfig_paths!

    system "meson", "setup", "build", "-Dpygobject-override-dir=#{site_packages}", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <gom/gom.h>

      int main(int argc, char *argv[]) {
        GType type = gom_error_get_type();
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs gom-1.0").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
