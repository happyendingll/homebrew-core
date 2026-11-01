class QuickjsNg < Formula
  desc "QuickJS, the Next Generation: a mighty JavaScript engine"
  homepage "https://quickjs-ng.github.io/quickjs/"
  url "https://github.com/quickjs-ng/quickjs/archive/refs/tags/v0.18.0.tar.gz"
  sha256 "28bcd89aa3683fd2a946537e5ce3f11cc46b5cbf3383c7561aaef3df5ff9f1dd"
  license "MIT"
  compatibility_version 1
  head "https://github.com/quickjs-ng/quickjs.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "78dff0d293f7e3cf826c27e696cab2453f6a48ade533da0d2c42f3be24f1b2e7"
  end

  depends_on "cmake" => :build

  conflicts_with "quickjs", because: "both install a `qjs` binary"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
      "-DBUILD_SHARED_LIBS=ON",
      "-DQJS_BUILD_LIBC=ON",
      "-DCMAKE_MACOSX_RPATH=OFF",
      *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    output = shell_output("#{bin}/qjs --eval 'const js=\"JS\"; console.log(`Q${js}${(7 + 35)}`);'")
    assert_match "QJS42", output

    test_file = testpath/"test.js"
    test_file.write "console.log('hello');"
    system bin/"qjsc", test_file
    assert_path_exists testpath/"out.c"
  end
end
