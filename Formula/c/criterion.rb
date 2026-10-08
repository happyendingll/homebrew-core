class Criterion < Formula
  desc "Cross-platform C and C++ unit testing framework for the 21st century"
  homepage "https://github.com/Snaipe/Criterion"
  url "https://github.com/Snaipe/Criterion/releases/download/v2.5.0/criterion-2.5.0.tar.xz"
  sha256 "740d5a9c00ca6f58f59dc20ba1ebecb3505d28287a8fe4ea3029c7f8a1906496"
  license "MIT"
  revision 1
  head "https://github.com/Snaipe/Criterion.git", branch: "bleeding"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "4d25b3afcfa92829e088b31bc6b718b289b6898316eff58ee5cee2acafa69631"
  end

  depends_on "cmake" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "libgit2"
  depends_on "nanomsg"
  depends_on "nanopb"

  uses_from_macos "libffi"

  deny_network_access!

  def subprojects = %w[boxfort debugbreak klib]

  def fetch
    system "meson", "subprojects", "download", *subprojects if build.head?
  end

  def install
    system "meson", "setup", "build", "--force-fallback-for=#{subprojects.join(",")}", *std_meson_args
    system "meson", "compile", "-C", "build"
    system "meson", "install", "--skip-subprojects", "-C", "build"
  end

  test do
    (testpath/"test-criterion.c").write <<~C
      #include <criterion/criterion.h>

      Test(suite_name, test_name)
      {
        cr_assert(1);
      }
    C

    system ENV.cc, "test-criterion.c", "-I#{include}", "-L#{lib}", "-lcriterion", "-o", "test-criterion"
    # Running tests needs the runner's `/tmp` Unix socket, which the test sandbox denies, so only list them
    assert_match "suite_name: 1 test", shell_output("./test-criterion --list")
    assert_match version.to_s, shell_output("./test-criterion --version 2>&1")
  end
end
