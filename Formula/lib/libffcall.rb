class Libffcall < Formula
  desc "GNU Foreign Function Interface library"
  homepage "https://www.gnu.org/software/libffcall/"
  url "https://ftpmirror.gnu.org/libffcall/libffcall-2.6.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libffcall/libffcall-2.6.tar.gz"
  sha256 "7e3951d642a1884adaf7f15c60df1bf8fbde686daa9fa69df1a514471b8cff39"
  license "GPL-2.0-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "9945061f0f95fcacb68717bf1ccfeee02ab2b03fbf7628e45769af086bcc7618"
  end

  conflicts_with "epics-base", because: "both install `callback.h` header"

  deny_network_access!

  def install
    ENV.deparallelize
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"callback.c").write <<~C
      #include <stdio.h>
      #include <callback.h>

      typedef char (*char_func_t) ();

      void function (void *data, va_alist alist)
      {
        va_start_char(alist);
        va_return_char(alist, *(char *)data);
      }

      int main() {
        char *data = "abc";
        callback_t callback = alloc_callback(&function, data);
        printf("%s\\n%c\\n",
          is_callback(callback) ? "true" : "false",
          ((char_func_t)callback)());
        free_callback(callback);
        return 0;
      }
    C
    flags = ["-L#{lib}", "-lffcall", "-I#{lib}/libffcall-#{version}/include"]
    system ENV.cc, "-o", "callback", "callback.c", *(flags + ENV.cflags.to_s.split)
    output = shell_output("#{testpath}/callback")
    assert_equal "true\na\n", output
  end
end
