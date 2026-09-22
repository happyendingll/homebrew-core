class Libyojimbo < Formula
  desc "Secure client/server network protocol library for multiplayer games"
  homepage "https://github.com/mas-bandwidth/yojimbo"
  url "https://github.com/mas-bandwidth/yojimbo/archive/refs/tags/v1.13.5.tar.gz"
  sha256 "ff78348e6ce6fa47b94c826516b4d8ca55f5b0d3aa4d0be1adc10ed80fdcbeb1"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "5435347a17d2893a31d6ae7b5e0fa53db5183c25d0a250b5b634f1852558dcbc"
  end

  depends_on "cmake" => :build

  depends_on "libsodium"
  depends_on "netcode"
  depends_on "reliable"
  depends_on "serialize"

  deny_network_access!
  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DYOJIMBO_SYSTEM_DEPS=ON",
                    "-DYOJIMBO_BUILD_TESTS=OFF",
                    "-DBUILD_SHARED_LIBS=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <yojimbo.h>

      int main() {
        if (!InitializeYojimbo()) {
          return 1;
        }
        ShutdownYojimbo();
        return 0;
      }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-lyojimbo", "-o", "test"
    system "./test"
  end
end
