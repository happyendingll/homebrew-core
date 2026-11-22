class ProxychainsNg < Formula
  desc "Hook preloader"
  homepage "https://github.com/rofl0r/proxychains-ng"
  url "https://github.com/rofl0r/proxychains-ng/archive/refs/tags/v4.18.tar.gz"
  sha256 "23000aaeee4702048580d9f4ed46cf1ce07917f6e3b8a08334df48fd74b66453"
  license "GPL-2.0-or-later"
  head "https://github.com/rofl0r/proxychains-ng.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1bc36d497c0e780d5738bec90ff1fa207c929ecbeb3adf1da20eafbcf7a5c4f5"
  end

  deny_network_access!

  def install
    system "./configure", *std_configure_args, "--sysconfdir=#{etc}"
    system "make"
    system "make", "install"
    system "make", "install-config"
  end

  test do
    assert_match "config file found", shell_output("#{bin}/proxychains4 test 2>&1", 1)
  end
end
