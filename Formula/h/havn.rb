class Havn < Formula
  desc "Fast configurable port scanner with reasonable defaults"
  homepage "https://github.com/mrjackwills/havn"
  url "https://github.com/mrjackwills/havn/archive/refs/tags/v0.3.10.tar.gz"
  sha256 "3706e7c986cb5641ddd20e66d743ae8d978c7b8fd37075644a07e592fb991746"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ee378c2ad58d08b021390558f2fe0e1e5b85cd8ea023d46ebb70c844ed7d5604"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    output = shell_output("#{bin}/havn example.com -p 443 -r 6")
    assert_match "1 open\e[0m, \e[31m0 closed", output

    assert_match version.to_s, shell_output("#{bin}/havn --version")
  end
end
