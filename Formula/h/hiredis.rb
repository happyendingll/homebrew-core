class Hiredis < Formula
  desc "Minimalistic client for Redis"
  homepage "https://github.com/redis/hiredis"
  url "https://github.com/redis/hiredis/archive/refs/tags/v1.4.1.tar.gz"
  sha256 "ca3180359a8b1275838a45415851f8cd5c411e27bdbf18f4823012e45507d2e4"
  license "BSD-3-Clause"
  revision 1
  compatibility_version 2
  head "https://github.com/redis/hiredis.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "33c240b01e911bf6f7b73d89e18587ece0fc7702858d1cc06237811a62a37151"
  end

  depends_on "openssl@4"

  def install
    system "make", "install", "PREFIX=#{prefix}", "USE_SSL=1"
    pkgshare.install "examples"
  end

  test do
    # running `./test` requires a database to connect to, so just make
    # sure it compiles
    system ENV.cc, pkgshare/"examples/example.c", "-o", testpath/"test",
                   "-I#{include}/hiredis", "-L#{lib}", "-lhiredis"
    assert_path_exists testpath/"test"
  end
end
