class NgLog < Formula
  desc "C++ library for application-level logging"
  homepage "https://ng-log.github.io/ng-log/"
  license "BSD-3-Clause"
  head "https://github.com/ng-log/ng-log.git", branch: "master"

  stable do
    url "https://github.com/ng-log/ng-log/archive/refs/tags/v0.8.4.tar.gz"
    sha256 "e154857d99d4ab6246a1bbde607ddb60f4bd6b1912c4f044a81f688cc89fcdd0"

    depends_on "gflags"
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "3e87bdb50934a9ddb4a65ddce91c548738a6130ef460444e91e848c72813dad6"
  end

  depends_on "cmake" => [:build, :test]

  deny_network_access!

  def install
    # Not building glog compatibility layer as most dependents don't work with it
    args = %w[
      -DBUILD_COMPAT=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_SHARED_LIBS=ON
      -DWITH_PKGCONFIG=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <ng-log/logging.h>

      int main(int argc, char* argv[]) {
        nglog::InitializeLogging(argv[0]);
        LOG(INFO) << "test";
      }
    CPP

    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0)
      find_package(ng-log CONFIG REQUIRED)
      add_executable(test test.cpp)
      target_link_libraries(test ng-log::ng-log)
    CMAKE

    ENV["TMPDIR"] = testpath
    system "cmake", "-S", ".", "-B", "build"
    system "cmake", "--build", "build"
    system "./build/test"

    assert_path_exists testpath/"test.INFO"
    assert_match "test.cpp:5] test", File.read("test.INFO")
  end
end
