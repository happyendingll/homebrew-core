class Gtkx3 < Formula
  desc "Toolkit for creating graphical user interfaces"
  homepage "https://gtk.org/"
  url "https://download.gnome.org/sources/gtk/3.24/gtk-3.24.52.tar.xz"
  sha256 "80931fa472a77b9a164f6740e3c0b444fac6770054632d35a7ff9d679e5e7b9f"
  license "LGPL-2.0-or-later"
  revision 1
  compatibility_version 1

  livecheck do
    url :stable
    regex(/gtk\+?[._-](3\.([0-8]\d*?)?[02468](?:\.\d+)*?)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 sequoia: "fbef811cf105a77849f684f1e8c64a3ef0ed121227b229512ca1a7df10e6dcc4"
  end

  depends_on "docbook" => :build
  depends_on "docbook-xsl" => :build
  depends_on "gettext" => :build
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]

  depends_on "at-spi2-core"
  depends_on "cairo"
  depends_on "fribidi"
  depends_on "gdk-pixbuf"
  depends_on "glib"
  depends_on "gsettings-desktop-schemas"
  depends_on "harfbuzz"
  depends_on "hicolor-icon-theme"
  depends_on "libepoxy"
  depends_on "pango"

  uses_from_macos "libxslt" => :build # for xsltproc

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "cmake" => :build

    depends_on "fontconfig"
    depends_on "iso-codes"
    depends_on "libx11"
    depends_on "libxdamage"
    depends_on "libxext"
    depends_on "libxfixes"
    depends_on "libxi"
    depends_on "libxinerama"
    depends_on "libxkbcommon"
    depends_on "libxrandr"
    depends_on "wayland"
    depends_on "wayland-protocols"
    depends_on "xorgproto"
  end

  # Fix macOS focus regression introduced in GTK 3.24.52:
  # New dialogs do not receive focus on macOS.
  # Remove for GTK 3.24.53 or later.
  patch do
    url "https://github.com/GNOME/gtk/commit/f80b61d6c8d6de0ce80c29052590c359a7f4b465.patch?full_index=1"
    sha256 "5f9e57e0824e35fdf78c3c388e084a840909c0d4c760e7fec69d99b2326a37fd"
    type :backport
    resolves "https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/9951"
  end

  # Fix macOS focus regression introduced in GTK 3.24.52:
  # Closed dialogs do not restore parent focus on macOS.
  # Remove for GTK 3.24.53 or later.
  patch do
    url "https://github.com/GNOME/gtk/commit/9667dc9166513ba0e99043920cf80562f8a8b926.patch?full_index=1"
    sha256 "3fc4ea96f8be403233421953da572744e4806d76cc2b1ec2d18af79ddc7f8030"
    type :backport
    resolves "https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/10037"
  end

  def install
    args = %w[
      -Dgtk_doc=false
      -Dman=true
      -Dintrospection=true
    ]

    if OS.mac?
      args << "-Dquartz_backend=true"
      args << "-Dx11_backend=false"
    end

    # ensure that we don't run the meson post install script
    ENV["DESTDIR"] = "/"

    # Find our docbook catalog
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration"

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    bin.install_symlink bin/"gtk-update-icon-cache" => "gtk3-update-icon-cache"
    man1.install_symlink man1/"gtk-update-icon-cache.1" => "gtk3-update-icon-cache.1"
  end

  post_install_steps do
    compile_gsettings_schemas
    run "gtk3-update-icon-cache", args: ["-f", "-t", "{{HOMEBREW_PREFIX}}/share/icons/hicolor"], base: :bin
    run "gtk-query-immodules-3.0", base:        :bin,
                                   stdout_path: "{{HOMEBREW_PREFIX}}/lib/gtk-3.0/3.0.0/immodules.cache"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <gtk/gtk.h>

      int main(int argc, char *argv[]) {
        gtk_disable_setlocale();
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs gtk+-3.0").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
    # include a version check for the pkg-config files
    assert_match version.to_s, shell_output("cat #{lib}/pkgconfig/gtk+-3.0.pc").strip
  end
end
