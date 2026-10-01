class Panache < Formula
  desc "Language server, formatter, and linter for Markdown, Quarto, and R Markdown"
  homepage "https://panache.bz"
  url "https://github.com/jolars/panache/archive/refs/tags/v3.13.0.tar.gz"
  sha256 "65b5b9da0ea2f7cf04e38e003102683bcaeca97e4c5df5dc4f77eda5fd7568b5"
  license "MIT"
  head "https://github.com/jolars/panache.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "8b4af3b1ce40e589619f8ab9f017d47ee111bf5a47307d5955c35cc9b38d9f7c"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    input = <<~MARKDOWN
      # Heading

      * one
      * two
    MARKDOWN

    output = pipe_output("#{bin}/panache format -", input)
    assert_match "- one", output
    assert_match "- two", output
  end
end
