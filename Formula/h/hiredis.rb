class Hiredis < Formula
  desc "Minimalistic client for Redis"
  homepage "https://github.com/redis/hiredis"
  url "https://github.com/redis/hiredis/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "eec7ef8641d221e144a58d5ef8d733c8c75c7fd487097a233aacb4fa33981cfb"
  license "BSD-3-Clause"
  compatibility_version 3
  head "https://github.com/redis/hiredis.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "d5a868f27e4cb751bac69e0b9da9939106bfc2cc90862d7abbe3ade1c25a58f6"
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
