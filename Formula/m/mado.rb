class Mado < Formula
  desc "Fast Markdown linter written in Rust"
  homepage "https://github.com/akiomik/mado"
  url "https://github.com/akiomik/mado/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "6df6348a59170c19858d24512ba0a7eba9a5b5ec51f3f2bfa14e32327cc0f806"
  license "Apache-2.0"
  head "https://github.com/akiomik/mado.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "df4d911f7b6f685f7ad49fac8e34244927adb2a72ed8a01b7b6f907b7279c8db"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mado --version")

    (testpath/"bad.md").write <<~MARKDOWN
      # Heading 1
      body without blank line
    MARKDOWN
    refute_empty shell_output("#{bin}/mado check #{testpath}/bad.md 2>&1", 1)

    (testpath/"good.md").write <<~MARKDOWN
      # Heading 1

      body with blank line
    MARKDOWN
    assert_match "All checks passed!", shell_output("#{bin}/mado check #{testpath}/good.md")
  end
end
