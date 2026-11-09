class XcbUtilCursor < Formula
  desc "XCB cursor library (replacement for libXcursor)"
  homepage "https://xcb.freedesktop.org"
  url "https://xcb.freedesktop.org/dist/xcb-util-cursor-0.1.6.tar.xz"
  sha256 "fdeb8bd127873519be5cc70dcd0d3b5d33b667877200f9925a59fdcad8f7a933"
  license "X11"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "6c964e73f65087130975db03e9eb222a1b36442005c4903546f6a3ee39e7c7ea"
  end

  head do
    url "https://gitlab.freedesktop.org/xorg/lib/libxcb-cursor.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "util-macros" => :build
  end

  depends_on "pkgconf" => [:build, :test]
  depends_on "libxcb"
  depends_on "xcb-util"
  depends_on "xcb-util-image"
  depends_on "xcb-util-renderutil"

  uses_from_macos "m4" => :build

  deny_network_access!

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-silent-rules",
                          "--datadir=#{HOMEBREW_PREFIX}/share",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          *std_configure_args
    system "make"
    system "make", "install"

    # Workaround to allow brew to record binary_relocation_files as directory needs to exist
    (share/"icons").mkpath
    touch share/"icons/.keepme.#{name}"
  end

  test do
    flags = shell_output("pkg-config --cflags --libs xcb-util xcb-cursor").chomp.split
    assert_includes flags, "-I#{include}"
    assert_includes flags, "-L#{lib}"
    (testpath/"test.c").write <<~C
      #include <xcb/xcb.h>
      #include <xcb/xcb_util.h>
      #include <xcb/xcb_cursor.h>

      int main(int argc, char *argv[]) {
        int screennr;
        xcb_connection_t *conn = xcb_connect(NULL, &screennr);
        if (conn == NULL || xcb_connection_has_error(conn))
          return 1;

        xcb_screen_t *screen = xcb_aux_get_screen(conn, screennr);
        xcb_cursor_context_t *ctx;
        if (xcb_cursor_context_new(conn, screen, &ctx) < 0)
          return 1;

        xcb_cursor_t cid = xcb_cursor_load_cursor(ctx, "watch");
        return 0;
      }
    C
    system ENV.cc, "test.c", *flags
  end
end
