class Sslscan < Formula
  desc "Test SSL/TLS enabled services to discover supported cipher suites"
  homepage "https://github.com/rbsec/sslscan"
  url "https://github.com/rbsec/sslscan/archive/refs/tags/2.2.3.tar.gz"
  sha256 "b0498467604c3f4eb7a1b3258ee9f37b709f7844d7edf338d40e85af40ede960"
  license "GPL-3.0-or-later" => { with: "cryptsetup-OpenSSL-exception" }
  head "https://github.com/rbsec/sslscan.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "b7d0d530ef08c75e46120547fc57c075a20cdbb4ed3c8e7b04556fdc9f3b8215"
  end

  depends_on "openssl@3"

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sslscan --version")
    system bin/"sslscan", "google.com"
  end
end
