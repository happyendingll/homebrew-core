class Comrak < Formula
  desc "CommonMark + GFM compatible Markdown parser and renderer"
  homepage "https://comrak.ee"
  url "https://github.com/kivikakk/comrak/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "bec24b69764da2f5e904503b3c27cd90720ab21e13c3ee5e09c36459ae377d27"
  license "BSD-2-Clause"
  head "https://github.com/kivikakk/comrak.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "efa4da357aa32ba10a6d0becd1345abeb3ec69549bf4a79fdb7bb4fede24d8e7"
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
    assert_match version.to_s, shell_output("#{bin}/comrak --version")

    (testpath/"test.md").write <<~MARKDOWN
      # Hello, World!

      This is a test of the **comrak** Markdown parser.
    MARKDOWN

    output = shell_output("#{bin}/comrak test.md")
    assert_match "<h1>Hello, World!</h1>", output
    assert_match "<p>This is a test of the <strong>comrak</strong> Markdown parser.</p>", output
  end
end
