class Rtmidi < Formula
  desc "API for realtime MIDI input/output"
  homepage "https://github.com/thestk/rtmidi"
  url "https://github.com/thestk/rtmidi/archive/refs/tags/6.1.0.tar.gz"
  sha256 "809ce56bfa67b80afcfa566927ce242a60b6f4c1bacc7e89486fbcf5624c5721"
  license "MIT"
  compatibility_version 1
  head "https://github.com/thestk/rtmidi.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "b977252a003d5bf4013118f3d53f676d6d59af46a5ab2845fe96696f952655c8"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  on_linux do
    depends_on "alsa-lib"
    depends_on "jack"
  end

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", "-DRTMIDI_BUILD_TESTING=OFF", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include "RtMidi.h"
      #include <iostream>
      #include <vector>
      int main() {
        std::vector<RtMidi::Api> apis;
        RtMidi::getCompiledApi(apis);
        for (auto api : apis) std::cout << RtMidi::getApiName(api) << "\\n";
      }
    CPP
    system ENV.cxx, "test.cpp", "-o", "test", "-std=c++11", "-I#{include}/rtmidi", "-L#{lib}", "-lrtmidi"
    # Creating a MIDI client needs a reachable MIDIServer, which headless macOS 27 CI lacks (kMIDINoConnection)
    assert_match OS.mac? ? "core" : "alsa", shell_output("./test")
  end
end
