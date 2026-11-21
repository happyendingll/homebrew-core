class Libjwt < Formula
  desc "JSON Web Token C library"
  homepage "https://libjwt.io/"
  url "https://github.com/benmcollins/libjwt/archive/refs/tags/v3.7.0.tar.gz"
  sha256 "d521d7fbf0794afa1bed4c806cda26fd5cf7991d7b6a5cec0274dccc6891288a"
  license "MPL-2.0"
  head "https://github.com/benmcollins/libjwt.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "4ef049edbe958681670daaac7b0594a75aff32b9ff51c9391929cecd64b18074"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "jansson"
  depends_on "openssl@4"

  def install
    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DWITH_TESTS=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdlib.h>
      #include <jwt.h>

      int main(void) {
        jwt_builder_t *builder = jwt_builder_new();
        char *token = jwt_builder_generate(builder);
        free(token);
        jwt_builder_free(builder);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-ljwt", "-o", "test"
    system "./test"
  end
end
