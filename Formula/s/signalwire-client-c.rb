class SignalwireClientC < Formula
  desc "SignalWire C Client SDK"
  homepage "https://github.com/signalwire/signalwire-c"
  url "https://github.com/signalwire/signalwire-c/archive/refs/tags/v2.0.7.tar.gz"
  sha256 "8b06862b0535d8ff4e3f0ca7cf34cebcf24972744dc251080131e517b067e60e"
  license "MIT"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "576a2d7790b70c2d4b5aa0322b70a4a573ca82fe349a6847887d6f8387c1c8fd"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "libks"
  depends_on "openssl@4"

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

    libks_major = Formula["libks"].version.major
    modules = ["signalwire_client#{version.major}", "libks#{libks_major}"]
    flags = Utils.safe_popen_read("pkgconf", "--cflags", "--libs", *modules).chomp.split
    openssl_include = dep("openssl").opt_include
    system ENV.cc, "test.c", "-o", "test", "-I#{openssl_include}", *flags
    system "./test"
  end
end
