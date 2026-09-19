class GnuSmalltalk < Formula
  desc "Implementation of the Smalltalk language"
  homepage "https://www.gnu.org/software/smalltalk/"
  license "GPL-2.0-or-later"
  revision 10

  stable do
    url "https://ftpmirror.gnu.org/smalltalk/smalltalk-3.2.5.tar.xz"
    mirror "https://ftp.gnu.org/gnu/smalltalk/smalltalk-3.2.5.tar.xz"
    sha256 "819a15f7ba8a1b55f5f60b9c9a58badd6f6153b3f987b70e7b167e7755d65acc"

    # Backport fix to support ARM macOS and fix build with Xcode 15+
    # Ref: https://github.com/gnu-smalltalk/smalltalk/commit/bf3fd4b501c71efa86d7f91d5127cab621245a8d
    # Ref: https://github.com/gnu-smalltalk/smalltalk/commit/7456c7a4fe34210ad3d34b6a596dc992045d3830
    on_macos do
      patch :DATA
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "334c35d0294ce8132c3f5b49acb10ad51e85eb6db925abfb0d0ac2f495875b0f"
  end

  head do
    url "https://github.com/gnu-smalltalk/smalltalk.git", branch: "master"

    on_system :linux, macos: :ventura_or_newer do
      depends_on "texinfo" => :build
    end
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gawk" => :build
  depends_on "pkgconf" => :build
  depends_on "gdbm"
  depends_on "gmp"
  depends_on "gnutls"
  depends_on "libsigsegv"
  depends_on "libtool"
  depends_on "readline"

  uses_from_macos "zip" => :build
  uses_from_macos "expat"
  uses_from_macos "libffi"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    # Fix compile with newer Clang
    if DevelopmentTools.clang_build_version >= 1500
      ENV.append_to_cflags "-Wno-implicit-function-declaration"
      ENV.append_to_cflags "-Wno-incompatible-function-pointer-types"
    end

    args = %W[
      --disable-gtk
      --with-lispdir=#{elisp}
      --with-readline=#{formula_opt_lib("readline")}
      --without-tcl
      --without-tk
      --without-x
    ]

    # K&R function definitions in the bundled getopt are invalid in the C23 default that autoconf 2.73 picks
    ENV["ac_cv_prog_cc_c23"] = "no"
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *args, *std_configure_args
    ENV.deparallelize if build.head?
    system "make"
    system "make", "install"
  end

  test do
    path = testpath/"test.gst"
    path.write "0 to: 9 do: [ :n | n display ]\n"

    assert_match "0123456789", shell_output("#{bin}/gst #{path}")
  end
end

__END__
--- a/libgst/sysdep/posix/mem.c
+++ b/libgst/sysdep/posix/mem.c
@@ -225,7 +225,7 @@ PTR
 anon_mmap_commit (PTR base, size_t size)
 {
   PTR result = mmap (base, size,
-   		     PROT_READ | PROT_WRITE | PROT_EXEC,
+		     PROT_READ | PROT_WRITE,
 		     MAP_ANON | MAP_PRIVATE | MAP_FIXED, -1, 0);

   return UNCOMMON (result == MAP_FAILED) ? NULL : result;
--- a/Makefile.am
+++ b/Makefile.am
@@ -110,7 +110,7 @@ bin_PROGRAMS = gst
 gst_SOURCES = main.c
 gst_LDADD = libgst/libgst.la lib-src/library.la @ICON@
 gst_DEPENDENCIES = libgst/libgst.la lib-src/library.la @ICON@
-gst_LDFLAGS = -export-dynamic $(RELOC_LDFLAGS) $(LIBFFI_EXECUTABLE_LDFLAGS)
+gst_LDFLAGS = -export-dynamic $(RELOC_LDFLAGS)
 
 # The single gst-tool executable is installed with multiple names, hence
 # we use noinst here.
@@ -118,7 +118,7 @@ noinst_PROGRAMS = gst-tool
 gst_tool_SOURCES = gst-tool.c
 gst_tool_LDADD = libgst/libgst.la lib-src/library.la @ICON@
 gst_tool_DEPENDENCIES = libgst/libgst.la lib-src/library.la @ICON@
-gst_tool_LDFLAGS = -export-dynamic $(RELOC_LDFLAGS) $(LIBFFI_EXECUTABLE_LDFLAGS)
+gst_tool_LDFLAGS = -export-dynamic $(RELOC_LDFLAGS)
 
 # Used to call the Unix zip from Wine
 EXTRA_PROGRAMS = winewrapper
