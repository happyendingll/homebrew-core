class Libdpp < Formula
  desc "C++ Discord API Bot Library"
  homepage "https://dpp.dev/"
  url "https://github.com/brainboxdotcc/DPP/archive/refs/tags/v10.1.7.tar.gz"
  sha256 "8624c6bea34c9edbf42f363c713a74cb3ecd9b0b6828e8f4527fd01ac527fa37"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "c8a97c9c9305923ae5e95daa0f8156fda0f1ebbdcd4f4b05e7231448f18428c9"
  end

  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "openssl@4"
  depends_on "opus"
  depends_on "pkgconf"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DDPP_BUILD_TEST=OFF",
                    "-DDPP_NO_CONAN=ON",
                    "-DDPP_NO_VCPKG=ON",
                    "-DDPP_USE_EXTERNAL_JSON=ON",
                    "-DRUN_LDCONFIG=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <dpp/dpp.h>
      #include <unistd.h> // for alarm

      void timeout_handler(int signum) {
          std::cerr << "Connection error: timed out" << std::endl;
          exit(1);
      }

      int main() {
          std::signal(SIGALRM, timeout_handler);
          alarm(2);

          dpp::cluster bot("invalid_token");

          bot.on_log(dpp::utility::cout_logger());

          try {
              bot.start(dpp::st_wait);
          }
          catch (const dpp::connection_exception &e) {
              std::cout << "Connection error: " << e.what() << std::endl;
              return 1;
          }
          catch (const dpp::invalid_token_exception &e) {
              std::cout << "Invalid token." << std::endl;
              return 1;
          }
          return 0;
      }
    CPP
    system ENV.cxx, "-std=c++20", "-L#{lib}", "-I#{include}", "test.cpp", "-o", "test", "-ldpp"
    assert_match "Connection error", shell_output("./test 2>&1", 1)
  end
end
