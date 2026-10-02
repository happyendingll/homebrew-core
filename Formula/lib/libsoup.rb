class Libsoup < Formula
  desc "HTTP client/server library for GNOME"
  homepage "https://wiki.gnome.org/Projects/libsoup"
  url "https://download.gnome.org/sources/libsoup/3.8/libsoup-3.8.0.tar.xz"
  sha256 "bbf08fa3e03a88c31a3d27a0d87cb422e9490f2d08e149211103df6d638a2238"
  license "LGPL-2.0-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "9a46d88b5d6ba623df56008664138e6fffe6a85b3c12d80e761a437e1a6921b2"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "vala" => :build

  depends_on "glib"
  depends_on "glib-networking" => :no_linkage
  depends_on "libnghttp2"
  depends_on "libpsl"
  depends_on "sqlite"
  depends_on "zstd"

  uses_from_macos "python" => :build
  uses_from_macos "krb5"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "brotli"
    depends_on "zlib-ng-compat"
  end

  allow_network_access! :test

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    # if this test start failing, the problem might very well be in glib-networking instead of libsoup
    (testpath/"test.c").write <<~C
      #include <libsoup/soup.h>

      int main(int argc, char *argv[]) {
        SoupMessage *msg = soup_message_new(SOUP_METHOD_GET, "https://brew.sh");
        SoupSession *session = soup_session_new();
        GError *error = NULL;
        GBytes *bytes = soup_session_send_and_read(session, msg, NULL, &error); // blocks

        if(error) {
          g_error_free(error);
          return 1;
        }

        g_object_unref(msg);
        g_object_unref(session);
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs libsoup-3.0").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
