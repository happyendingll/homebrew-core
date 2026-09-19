class Slowhttptest < Formula
  desc "Simulates application layer denial of service attacks"
  homepage "https://github.com/shekyan/slowhttptest"
  url "https://github.com/shekyan/slowhttptest/archive/refs/tags/v1.10.0.tar.gz"
  sha256 "9e1e18e32c761b97eb92d4c3680bcbe60dc2fae852c1dc339460ac50c51be444"
  license "Apache-2.0"
  head "https://github.com/shekyan/slowhttptest.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "a27957734899c10241b1a05600fce37904145a39d1d596ec90a21fc3bd0ccba2"
  end

  depends_on "openssl@4"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"slowhttptest", "-u", "https://google.com",
                                  "-p", "1", "-r", "1", "-l", "1", "-i", "1"

    assert_match version.to_s, shell_output("#{bin}/slowhttptest -h", 1)
  end
end
