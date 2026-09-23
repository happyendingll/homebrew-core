class Funzzy < Formula
  desc "Lightweight file watcher"
  homepage "https://github.com/cristianoliveira/funzzy"
  url "https://github.com/cristianoliveira/funzzy/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "79c4e934ea2035b365b01d5bcb1c7b72e6cc089543fae29c71800ae274638c0a"
  license "MIT"
  head "https://github.com/cristianoliveira/funzzy.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0b78e18f4943bc58f55ee16df5a704f5bae9c08a2804ef590d2e37eca5ca3814"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system bin/"funzzy", "init"
    assert_match "## Funzzy events file", File.read(testpath/".watch.yaml")

    assert_match version.to_s, shell_output("#{bin}/funzzy --version")
  end
end
