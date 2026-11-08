class SignalwireClientC < Formula
  desc "SignalWire C Client SDK"
  homepage "https://github.com/signalwire/signalwire-c"
  url "https://github.com/signalwire/signalwire-c/archive/refs/tags/v2.0.6.tar.gz"
  sha256 "e49f1e2686058b1aa1ae30e84b00248da3d109b9b8fce682058f1b53c0e2280d"
  license "MIT"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "d21a8f59ccef810390fd2413b9284f9c4757259a912a3f1bb14e1a62be6e9620"
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

    modules = ["signalwire_client#{version.major}", "libks#{Formula["libks"].version.major}"]
    flags = Utils.safe_popen_read("pkgconf", "--cflags", "--libs", *modules).chomp.split
    system ENV.cc, "test.c", "-o", "test", "-I#{formula_opt_include("openssl@4")}", *flags
    system "./test"
  end
end
