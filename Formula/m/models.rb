class Models < Formula
  desc "Fast TUI and CLI for browsing AI models, benchmarks, and coding agents"
  homepage "https://reyamira.github.io/models/"
  url "https://github.com/reyamira/models/archive/refs/tags/v0.14.1.tar.gz"
  sha256 "74361e3fde193772cd0db2ce4c9394487e437c4d7e416ebfafb0af661291d58a"
  license "MIT"
  head "https://github.com/reyamira/models.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "48301dfe8e609d5faa990a00213cfa6d738d21a1dc864a76178914934853160d"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/models --version")
    assert_match "claude-code", shell_output("#{bin}/models agents list-sources")
  end
end
