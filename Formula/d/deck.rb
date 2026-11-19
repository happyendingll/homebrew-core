class Deck < Formula
  desc "Creates slide deck using Markdown and Google Slides"
  homepage "https://github.com/k1LoW/deck"
  url "https://github.com/k1LoW/deck/archive/refs/tags/v1.24.5.tar.gz"
  sha256 "cc3684ca91f6ad7289a3f8f07a08a38fc30e6b500c2495b99f29e60e2d06c36b"
  license "MIT"
  head "https://github.com/k1LoW/deck.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "863b7b1490de01c77dc5dcaf65cb4d3eb61e1a01d107fa3e929479645848e9b6"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/deck"

    generate_completions_from_executable(bin/"deck", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/deck --version")
    assert_match "presentation ID is required", shell_output("#{bin}/deck export 2>&1", 1)
  end
end
