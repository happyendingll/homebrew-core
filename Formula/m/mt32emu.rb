class Mt32emu < Formula
  desc "Multi-platform software synthesiser"
  homepage "https://github.com/munt/munt"
  url "https://github.com/munt/munt/archive/refs/tags/libmt32emu_2_8_4.tar.gz"
  sha256 "1080ee41fe1f9a2d9abc7ec010cb105a57576528708e3d0ef467b6a7d7fde92f"
  license "LGPL-2.1-or-later"
  compatibility_version 1
  head "https://github.com/munt/munt.git", branch: "master"

  livecheck do
    url :stable
    regex(/^libmt32emu[._-]v?(\d+(?:[._-]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.filter_map { |tag| tag[regex, 1]&.tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "f3efd219d9924c94e0d0e8da97a30b0f2d153d2f67cad2aba27d5239cf7b3394"
  end

  depends_on "cmake" => :build
  depends_on "libsamplerate"
  depends_on "libsoxr"

  deny_network_access!

  def install
    system "cmake", "-S", "mt32emu", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"mt32emu-test.c").write <<~C
      #include "mt32emu.h"
      #include <stdio.h>
      int main() {
        printf("%s", mt32emu_get_library_version_string());
      }
    C

    system ENV.cc, "mt32emu-test.c", "-I#{include}", "-L#{lib}", "-lmt32emu", "-o", "mt32emu-test"
    assert_match version.to_s, shell_output("./mt32emu-test")
  end
end
