class Libsolv < Formula
  desc "Library for solving packages and reading repositories"
  homepage "https://github.com/openSUSE/libsolv"
  url "https://github.com/openSUSE/libsolv/archive/refs/tags/0.7.40.tar.gz"
  sha256 "30f529ad39d23bdc284b81ea3ed29679162011fc5fb9392635db0b4d1c8e3511"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "8312eed5159b7d68343bc2638c7f85c173f393f4d6c0a7163d79465e791ab39f"
  end

  depends_on "cmake" => :build
  depends_on "rpm"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "bzip2"
  uses_from_macos "expat"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = %W[
      -DENABLE_STATIC=ON
      -DENABLE_SUSEREPO=ON
      -DENABLE_COMPS=ON
      -DENABLE_HELIXREPO=ON
      -DENABLE_DEBIAN=ON
      -DENABLE_MDKREPO=ON
      -DENABLE_ARCHREPO=ON
      -DENABLE_CUDFREPO=ON
      -DENABLE_CONDA=ON
      -DENABLE_APPDATA=ON
      -DMULTI_SEMANTICS=ON
      -DENABLE_LZMA_COMPRESSION=ON
      -DENABLE_BZIP2_COMPRESSION=ON
      -DENABLE_ZSTD_COMPRESSION=ON
      -DENABLE_ZCHUNK_COMPRESSION=ON
      -DENABLE_RPMDB=ON
      -DENABLE_RPMMD=ON
      -DENABLE_RPMPKG=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <solv/pool.h>
      #include <solv/repo.h>

      int main(int argc, char **argv) {
        Pool *pool = pool_create();

        Repo *repo = repo_create(pool, "test");

        pool_free(pool);
      }
    CPP
    system ENV.cc, "test.cpp", "-I#{include}", "-L#{lib}", "-lsolv", "-o", "test"
    system "./test"
  end
end
