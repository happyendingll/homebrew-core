class Dnswire < Formula
  desc "Library for encoding/decoding different DNS encapsulations"
  homepage "https://codeberg.org/DNS-OARC/dnswire"
  url "https://www.dns-oarc.net/files/dnswire/dnswire-0.5.1.tar.gz"
  sha256 "b0b52b95e20eda768256794097080b5f5725d9fe841ef03568c51987b02673b4"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "482cba7448bd8eb2bd88e65598efef601a039c06b75aa6859401f8a7da974d6a"
  end

  depends_on "pkgconf" => [:build, :test]
  depends_on "libuv"
  depends_on "protobuf-c"
  depends_on "tinyframe"

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <dnswire/version.h>
      #include <stdio.h>

      int main(int argc, char *argv[]) {
        printf("Version %s", DNSWIRE_VERSION_STRING);
        return 0;
      }
    C
    flags = shell_output("pkgconf --cflags --libs libdnswire").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    assert_match version.to_s, shell_output("./test")
  end
end
