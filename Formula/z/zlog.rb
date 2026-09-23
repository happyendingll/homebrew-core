class Zlog < Formula
  desc "High-performance C logging library"
  homepage "https://github.com/HardySimpson/zlog"
  url "https://github.com/HardySimpson/zlog/archive/refs/tags/1.2.19.tar.gz"
  sha256 "475df1b30be64190fd692de834ad4c45510f996188b5ecd4b6e3da2527c74a32"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "662d3363e8c08b222c7a8a57afab9e2b9c2aeeaa8d1faa77dd82eae682bf9efa"
  end

  on_macos do
    depends_on "make" => :build
  end

  deny_network_access!

  def install
    make = OS.mac? ? "gmake" : "make"

    system make, "PREFIX=#{prefix}"
    system make, "PREFIX=#{prefix}", "install"
  end

  test do
    (testpath/"zlog.conf").write <<~INI
      [formats]
      simple = "%m%n"
      [rules]
      my_cat.DEBUG    >stdout; simple
    INI
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <zlog.h>
      int main() {
        int rc;
        zlog_category_t *c;

        rc = zlog_init("zlog.conf");
        if (rc) {
          printf("init failed!");
          return -1;
        }

        c = zlog_get_category("my_cat");
        if (!c) {
          printf("get cat failed!");
          zlog_fini();
          return -2;
        }

        zlog_info(c, "hello, zlog!");
        zlog_fini();

        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-lzlog", "-pthread", "-o", "test"
    assert_equal "hello, zlog!\n", shell_output("./test")
  end
end
