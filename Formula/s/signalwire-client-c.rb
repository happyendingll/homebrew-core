class SignalwireClientC < Formula
  desc "SignalWire C Client SDK"
  homepage "https://github.com/signalwire/signalwire-c"
  url "https://github.com/signalwire/signalwire-c/archive/refs/tags/v2.0.5.tar.gz"
  sha256 "336c88a28015cf666bdbb070e9e11ce53dfd05baec074171fe8866945b68e8f9"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "086af7f80a89109c27062eb71449ebc02b91ef45b12c3306565814949808a816"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "libks"
  depends_on "openssl@3"

  def install
    # cotire builds a prefix header from the `clang -H` include list, which on macOS 27 also has `SDKSettings.json`
    system "cmake", "-S", ".", "-B", ".", "-DCOTIRE_ADDITIONAL_PREFIX_HEADER_IGNORE_EXTENSIONS=inc;inl;ipp;json",
                    *std_cmake_args
    system "cmake", "--build", "."
    system "cmake", "--install", "."
  end

  test do
    # https://github.com/signalwire/signalwire-c/blob/master/examples/client/main.c
    (testpath/"test.c").write <<~C
      #include "signalwire-client-c/client.h"

      int main(void) {
        swclt_init(KS_LOG_LEVEL_DEBUG);
        swclt_shutdown();
        return 0;
      }
    C

    modules = ["signalwire_client#{version.major}", "libks#{Formula["libks"].version.major}"]
    flags = Utils.safe_popen_read("pkgconf", "--cflags", "--libs", *modules).chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
