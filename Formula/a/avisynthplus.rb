class Avisynthplus < Formula
  desc "Improved version of the AviSynth frameserver"
  homepage "https://avs-plus.net"
  url "https://github.com/AviSynth/AviSynthPlus/archive/refs/tags/v3.7.6.tar.gz"
  sha256 "8c019a934189688e73fe1cd85e6768cc0bc120fe1f4a3310c889060283c9e083"
  license "GPL-2.0-or-later"
  compatibility_version 1
  head "https://github.com/AviSynth/AviSynthPlus.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "2c27129c46a8dbd3cbcf174f9fecb5fdb3595fc3b89b149d7df5e017b69b1d7a"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "devil" # for ImageSeq plugin.
  depends_on "sound-touch" # for TimeStretch plugin.

  on_linux do
    depends_on "hicolor-icon-theme"
  end

  deny_network_access!

  def install
    # Preserve per-file SIMD flags for code selected by runtime CPU detection.
    ENV.runtime_cpu_detection

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <avisynth/avisynth.h>
      int main() {
        IScriptEnvironment* env = CreateScriptEnvironment(AVISYNTH_INTERFACE_VERSION);
        if (!env) return 1;

        env->DeleteScriptEnvironment();
        return 0;
      }
    CPP
    system ENV.cxx, "test.cpp", "-o", "test", "-I#{include}", "-L#{lib}", "-lavisynth"
    system "./test"
  end
end
