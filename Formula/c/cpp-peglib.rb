class CppPeglib < Formula
  desc "Header-only PEG (Parsing Expression Grammars) library for C++"
  homepage "https://yhirose.github.io/cpp-peglib/"
  url "https://github.com/yhirose/cpp-peglib/archive/refs/tags/v1.25.0.tar.gz"
  sha256 "eb8e6ea258dab227e6f5a31fcc8597988dfca4d106d110d59610d005bc35695a"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "70de3abadf766f8a250b8bf73fefea38b907ea7407ab637c636e982da6d4c5c3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4a01e2422aef927166e7865138840721f79471c4c8fc4737c003cd1c63b687cc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c3ad9b7da3f4572c3defecf1accea5b23ad153d749208a494efc8491beebf27d"
    sha256 cellar: :any,                 arm64_linux:       "8c42eca4223eb85ebe885d20cb17b134b8da31884abc516ec0896f226b57c77f"
    sha256 cellar: :any,                 x86_64_linux:      "1c9bbf37ae761639055956584e4dc4f80f3f7175e4762b7b11e6a621530a5446"
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
