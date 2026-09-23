class Urx < Formula
  desc "Extracts URLs from OSINT Archives for Security Insights"
  homepage "https://urx.hahwul.com"
  url "https://github.com/hahwul/urx/archive/refs/tags/0.11.0.tar.gz"
  sha256 "ff8f5d9bbd4c3ca1c3cdafb17a4742bc0f8a132ca2edc9b76d9c871af3cb4dec"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "3877cdcf94a126e77b972034fc25549e199bad1be19a9cd2d0d92f55e3c6f8ce"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "urx #{version}", shell_output("#{bin}/urx --version")
    assert_match "https://brew.sh/", shell_output("#{bin}/urx brew.sh --providers=cc --include-sitemap")
  end
end
