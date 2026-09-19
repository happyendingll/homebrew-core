class Ttl < Formula
  desc "Modern traceroute/mtr-style TUI with hop stats and ASN/geo enrichment"
  homepage "https://github.com/lance0/ttl"
  url "https://github.com/lance0/ttl/archive/refs/tags/v0.23.0.tar.gz"
  sha256 "e3e2f88707f0ce22a329a91f2f2a2e2f33a5468470fe076c15357328156300a5"
  license "MIT"

  head "https://github.com/lance0/ttl.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "89a945351e704482298661ce1ca6be53681fe9b05a7afb9e60d9270cb6b20b87"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"ttl", "--completions", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match "ttl", shell_output("#{bin}/ttl --help")
    assert_match "Insufficient permissions", shell_output("#{bin}/ttl 127.0.0.1 2>&1", 1)
  end
end
