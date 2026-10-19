class Obscura < Formula
  desc "Headless browser for AI agents and web scraping"
  homepage "https://obscura.sh"
  url "https://github.com/h4ckf0r0day/obscura/archive/refs/tags/v0.2.5.tar.gz"
  sha256 "af287fa7658270a68ad6f1220197eb55035614a91b14295117da78e55494958a"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "4efcb480e4aa2e1a2a8a964b5510199b361531e251367068fd01f7576d2b1a20"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/obscura-cli", features: "render")
  end

  test do
    output = shell_output(
      "#{bin}/obscura fetch 'data:text/html,<title>Homebrew Test</title>' --eval 'document.title'",
    )
    assert_equal "Homebrew Test\n", output

    assert_equal "rgb(255, 0, 0)\n", shell_output(
      %Q(#{bin}/obscura fetch 'data:text/html,<style>p{color:red}</style><p>x' \
      --eval 'getComputedStyle(document.querySelector("p")).color'),
    )

    # obscura blocks fetches to loopback/private addresses by default (SSRF protection)
    blocked = shell_output("#{bin}/obscura fetch http://127.0.0.1:1/ 2>&1", 1)
    assert_match "private/internal IP address", blocked
  end
end
