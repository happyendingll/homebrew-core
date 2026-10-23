class Libconfig < Formula
  desc "Configuration file processing library"
  homepage "https://hyperrealm.github.io/libconfig/"
  url "https://github.com/hyperrealm/libconfig/archive/refs/tags/v1.8.3.tar.gz"
  sha256 "683f723d647befcdb36e1a4a61a83ae8c89dc7959ca872a7407b6c8152104162"
  license "LGPL-2.1-or-later"
  compatibility_version 1
  head "https://github.com/hyperrealm/libconfig.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "c8125e813a9c809847f296d4d25aa5710181b0c9c24ef07b43783d59f01c10e5"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  uses_from_macos "flex" => :build

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  def install
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libconfig.h>
      int main() {
        config_t cfg;
        config_init(&cfg);
        config_destroy(&cfg);
        return 0;
      }
    C
    system ENV.cc, testpath/"test.c", "-I#{include}",
           "-L#{lib}", "-lconfig", "-o", testpath/"test"
    system "./test"
  end
end
