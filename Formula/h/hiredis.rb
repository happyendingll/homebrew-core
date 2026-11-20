class Hiredis < Formula
  desc "Minimalistic client for Redis"
  homepage "https://github.com/redis/hiredis"
  url "https://github.com/redis/hiredis/archive/refs/tags/v1.5.1.tar.gz"
  sha256 "f5ec19151c0f4f15ca018c22b17b6f6739a672a4fc0c085b692aef69a154ebef"
  license "BSD-3-Clause"
  compatibility_version 3
  head "https://github.com/redis/hiredis.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "274c483b056dac0b72125013e84a5349f9e25e96a9d26fb5bdb8139213416c9b"
  end

  depends_on "openssl@4"

  deny_network_access!

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
