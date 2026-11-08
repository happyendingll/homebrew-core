class Awk < Formula
  desc "Text processing scripting language"
  homepage "https://www.cs.princeton.edu/~bwk/btl.mirror/"
  url "https://github.com/onetrueawk/awk/archive/refs/tags/20261106.tar.gz"
  sha256 "1b354fe6fa0089a959ef912085e7a064236d15a7d3c9e6ce86456c3b87d3f464"
  license "SMLNJ"
  head "https://github.com/onetrueawk/awk.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "893de823b371d0b60036d134eeef35c4a0bf46b1e9d676cedce1aad54ac6d9a5"
  end

  uses_from_macos "bison" => :build

  on_linux do
    conflicts_with "gawk", because: "both install an `awk` executable"
  end

  deny_network_access!

  def install
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}"
    bin.install "a.out" => "awk"
    man1.install "awk.1"
  end

  test do
    assert_match "test", pipe_output("#{bin}/awk '{print $1}'", "test", 0)
  end
end
