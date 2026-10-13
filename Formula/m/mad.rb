class Mad < Formula
  desc "MPEG audio decoder"
  homepage "https://codeberg.org/tenacityteam/libmad"
  url "https://codeberg.org/tenacityteam/libmad/releases/download/0.16.5/libmad-0.16.5.tar.gz"
  sha256 "f401b2ccf49c26ad0c3a6ef0179b1cbbff2406338b0603bb2033e6dcaf706114"
  license "GPL-2.0-or-later"
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "dedb2613979e316ba6947814b298abbd5fc64a423f134dcf327c3ae65dfd31e3"
  end

  depends_on "cmake" => :build

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build", "-DEXAMPLE=OFF",
                    "-DCMAKE_INSTALL_NAME_DIR=#{opt_lib}", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    pkgshare.install "examples/minimad.c"
  end

  test do
    system ENV.cc, pkgshare/"minimad.c", "-o", "minimad", "-I#{include}", "-L#{lib}", "-lmad"
    system "./minimad <#{test_fixtures("test.mp3")} >test.wav"
    assert_equal 4608, (testpath/"test.wav").size?
  end
end
