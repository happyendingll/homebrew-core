class Mado < Formula
  desc "Fast Markdown linter written in Rust"
  homepage "https://github.com/akiomik/mado"
  url "https://github.com/akiomik/mado/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "55e3c611a5096f7085e9d439c4ba91b8a8d749de6cd313ba09771d84f484607a"
  license "Apache-2.0"
  head "https://github.com/akiomik/mado.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "0cdd907ee4200615143b070d29f04de63d6180746adfc0ccdfad64d57288c7df"
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
