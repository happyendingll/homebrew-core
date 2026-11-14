class Sslscan < Formula
  desc "Test SSL/TLS enabled services to discover supported cipher suites"
  homepage "https://github.com/rbsec/sslscan"
  url "https://github.com/rbsec/sslscan/archive/refs/tags/2.2.4.tar.gz"
  sha256 "93674469cfbfea7326e5236165b1824df5fbab32a9e0499f03edc10b36befff2"
  license "GPL-3.0-or-later" => { with: "cryptsetup-OpenSSL-exception" }
  head "https://github.com/rbsec/sslscan.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "7be103d397edeaaf6638574ace3a33faa0b09be86020a73662e47bc3ceaed3c2"
  end

  depends_on "openssl@3" # TODO: OpenSSL 4 issue - https://github.com/rbsec/sslscan/issues/361

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sslscan --version")
    system bin/"sslscan", "google.com"
  end
end
