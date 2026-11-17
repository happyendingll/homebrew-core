class SlintCpp < Formula
  desc "C++ library and headers for the Slint UI toolkit"
  homepage "https://slint.dev/"
  url "https://github.com/slint-ui/slint/archive/refs/tags/v1.19.0.tar.gz"
  sha256 "9c15a9f6dfe94fbe96cb97dcb38207907403a67c9b23d8a93468ea1bb132246c"
  license "GPL-3.0-only"
  head "https://github.com/slint-ui/slint.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "4eb1cf41cf256c5e5d44e6a6c3b3a1757ec1a29ece9b1af0bd9d36581ba2e686"
  end

  depends_on "cmake" => :build
  depends_on "corrosion" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "fontconfig"
    depends_on "freetype"
  end

  # `skia-bindings` crate downloads skia during `:build` phase
  allow_network_access! :build

  def install
    # Optimizations recommended by upstream:
    # https://github.com/slint-ui/slint/blob/master/.github/workflows/cpp_package.yaml
    ENV["CARGO_INCREMENTAL"] = "false"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "fat"
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"

    extra_cmake_args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DSLINT_FEATURE_COMPILER=OFF
      -DSLINT_FEATURE_RENDERER_SKIA=ON
      -DSLINT_FEATURE_RENDERER_SKIA_OPENGL=ON
    ]

    extra_cmake_args << "-DSLINT_FEATURE_RENDERER_SKIA_VULKAN=ON" if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *extra_cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <slint.h>
      int main() {
          return 0;
      }
    CPP

    system ENV.cc, "test.cpp", "-std=c++20", "-I#{include}/slint", "-L#{lib}", "-lslint_cpp", "-o", "test"
    system "./test"
  end
end
