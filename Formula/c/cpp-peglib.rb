class CppPeglib < Formula
  desc "Header-only PEG (Parsing Expression Grammars) library for C++"
  homepage "https://yhirose.github.io/cpp-peglib/"
  url "https://github.com/yhirose/cpp-peglib/archive/refs/tags/v1.29.0.tar.gz"
  sha256 "a7f7722af528d345433ef42d3d0f52b4cb505f51a5a7f0c90c6f83eddeebf9ee"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "f6b8470287cfa4b09ca745305f584acf0ff58a558d4298f78285e4044e9956bc"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    args = %w[
      -DBUILD_TESTS=OFF
      -DPEGLIB_BUILD_LINT=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    bin.install "build/lint/peglint"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <peglib.h>

      int main() {
        peg::parser parser(R"(
          START <- [0-9]+
        )");

        std::string input = "12345";
        return parser.parse(input) ? 0 : 1;
      }
    CPP

    system ENV.cxx, "-std=c++17", "test.cpp", "-I#{include}", "-o", "test"
    system "./test"

    (testpath/"grammar.peg").write <<~EOS
      START <- [0-9]+ EOF
      EOF <- !.
    EOS

    (testpath/"source.txt").write "12345"

    output = shell_output("#{bin}/peglint --profile #{testpath}/grammar.peg #{testpath}/source.txt")
    assert_match "success", output
  end
end
