class Tinyframe < Formula
  desc "Minimalistic library for reading and writing the Frame Streams protocol"
  homepage "https://codeberg.org/DNS-OARC/tinyframe"
  url "https://www.dns-oarc.net/files/tinyframe/tinyframe-0.1.2.tar.gz"
  sha256 "181e18bf3e8067b5415f0179d1b35286bf1d379ba71bb89c8e6cc2a73c3cec8d"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "3aaef626b30dfbb42f2a89097685ce4c8bc814e611e2c8d42e4a52e225c81b16"
  end

  depends_on "pkgconf" => :test

  patch do
    on_macos do
      url "https://codeberg.org/smillernl/tinyframe/commit/c425d6c35edd05e3313baa5e5c87ef3b6e787118.patch"
      sha256 "8db7615be41f35cd9232d2039454c56118d2f904cd1eef5443a8a3b21a8a4926"
    end
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <tinyframe/version.h>
      #include <stdio.h>

      int main(int argc, char *argv[]) {
        printf("Version %s", TINYFRAME_VERSION_STRING);
        return 0;
      }
    C
    flags = shell_output("pkgconf --cflags --libs libtinyframe").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    assert_match version.to_s, shell_output("./test")
  end
end
