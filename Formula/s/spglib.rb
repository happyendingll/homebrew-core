class Spglib < Formula
  desc "C library for finding and handling crystal symmetries"
  homepage "https://spglib.readthedocs.io/en/latest/"
  url "https://github.com/spglib/spglib/archive/refs/tags/v2.8.0.tar.gz"
  sha256 "161562fa082da85a8ecda0339ddaac3714470434de60eb67978a960872cacf78"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "5953842868199fefb88db3cec1c996b50c39156349c552587499b91a581854ef"
  end

  depends_on "cmake" => [:build, :test]

  deny_network_access!

  def install
    # TODO: Fortran packaging is disabled for now because packaging does not pick it up properly
    # https://github.com/spglib/spglib/issues/352#issuecomment-1784943807
    common_args = %w[
      -DSPGLIB_WITH_Fortran=OFF
      -DSPGLIB_WITH_TESTS=OFF
    ]
    system "cmake", "-S", ".", "-B", "build_shared",
                    "-DSPGLIB_SHARED_LIBS=ON",
                    *common_args, *std_cmake_args
    system "cmake", "--build", "build_shared"
    system "cmake", "--install", "build_shared"

    system "cmake", "-S", ".", "-B", "build_static",
                    "-DSPGLIB_SHARED_LIBS=OFF",
                    *common_args, *std_cmake_args
    system "cmake", "--build", "build_static"
    system "cmake", "--install", "build_static"
  end

  test do
    (testpath / "test.c").write <<~C
      #include <stdio.h>
      #include <spglib.h>
      int main()
      {
        printf("%d.%d.%d", spg_get_major_version(), spg_get_minor_version(), spg_get_micro_version());
      }
    C

    (testpath / "CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.10)
      project(test_spglib LANGUAGES C)
      find_package(Spglib CONFIG REQUIRED COMPONENTS shared)
      add_executable(test_c test.c)
      target_link_libraries(test_c PRIVATE Spglib::symspg)
    CMAKE
    system "cmake", "-B", "build_shared"
    system "cmake", "--build", "build_shared"
    system "./build_shared/test_c"

    (testpath / "CMakeLists.txt").delete
    (testpath / "CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.10)
      project(test_spglib LANGUAGES C)
      find_package(Spglib CONFIG REQUIRED COMPONENTS static)
      add_executable(test_c test.c)
      target_link_libraries(test_c PRIVATE Spglib::symspg)
    CMAKE
    system "cmake", "-B", "build_static"
    system "cmake", "--build", "build_static"
    system "./build_static/test_c"
  end
end
