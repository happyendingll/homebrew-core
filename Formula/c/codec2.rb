class Codec2 < Formula
  desc "Open source speech codec"
  homepage "https://github.com/drowe67/codec2"
  # Linked from https://freedv.org/
  url "https://github.com/drowe67/codec2/archive/refs/tags/1.2.0.tar.gz"
  sha256 "cbccae52b2c2ecc5d2757e407da567eb681241ff8dadce39d779a7219dbcf449"
  license "LGPL-2.1-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :git do |tags, regex|
      malformed_tags = ["v1.03"].freeze
      tags.map do |tag|
        next if malformed_tags.include?(tag)

        tag[regex, 1]
      end
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "aba3d4f5d94951c1ead9524a5145e8941cb820e3f25daa461808578b64b04bb6"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test

  # Fix include dirs in codec2.pc so `#include <codec2/version.h>` in codec2.h resolves
  # when the prefix is not on the default include path (e.g. /opt/homebrew)
  patch do
    url "https://github.com/drowe67/codec2/commit/8241e30b7ca8784cfac6450b5c84c5b8722c53d5.patch?full_index=1"
    sha256 "e80197819d2168ab88aa455f406d24274bd2e79a42488dce44a754ecdcd79665"
    type :backport
    resolves "https://github.com/drowe67/codec2/pull/49"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
                    "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath,#{rpath}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    bin.install "build/demo/c2demo"
    bin.install Dir["build/src/c2*"]
  end

  test do
    # 8 bytes of raw audio data (silence).
    (testpath/"test.raw").write([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00].pack("C*"))
    system bin/"c2enc", "2400", "test.raw", "test.c2"

    (testpath/"test.c").write <<~C
      #include <codec2.h>
      int main(void) {
        struct CODEC2 *c2 = codec2_create(CODEC2_MODE_3200);
        if (!c2) return 1;
        codec2_destroy(c2);
        return 0;
      }
    C
    flags = shell_output("pkgconf --cflags --libs codec2").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
