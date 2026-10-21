class PdfcraftCli < Formula
  desc "Headless PdfCraft CLI and MCP server to create, edit, inspect and fill PDFs"
  homepage "https://getartcraft.com/apps/pdfcraft"
  url "https://github.com/storytold/pdfcraft/archive/refs/tags/v0.10.1.tar.gz"
  sha256 "1961a2bfbae96c2adb7edbb2438c5998d6df7a67bdcde42ab98e7f4a03097caf"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/storytold/pdfcraft.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e215d27646efebdbc5763c0666dfb7cb6e28b0c9de32328d05ac4c4d0b1722dc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1873c1049ea040f438286ee8a4f8de48b82356e3c121db7fd48d87bd64d1152b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c5db50a40b9dbc11a88338ac19619a6d171e6e47857a560679ff5e4aea8d0eca"
    sha256 cellar: :any,                 arm64_linux:       "1088e5b053a3f9a211f274a05543ad556c8651430ab2e5e38cfa8d1ebb65421a"
    sha256 cellar: :any,                 x86_64_linux:      "6e69895ff49685a47ce14c94bb7eb5630a9b4de2e8066c6d410ee84398e58f0f"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "apps/pdfcraft-cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pdfcraft-cli --version")

    pdf = test_fixtures("test.pdf")
    system bin/"pdfcraft-cli", "edit", pdf, "--rotate", "1:90",
           "--title", "Homebrew Test", "--out", "out.pdf"

    info = JSON.parse(shell_output("#{bin}/pdfcraft-cli info out.pdf"))
    assert_equal 1, info["pages"]
    assert_equal [800.0, 500.0], info["first_page_pt"]
    assert_equal "Homebrew Test", info["title"]
  end
end
