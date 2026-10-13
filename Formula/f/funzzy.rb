class Funzzy < Formula
  desc "Lightweight file watcher"
  homepage "https://github.com/cristianoliveira/funzzy"
  url "https://github.com/cristianoliveira/funzzy/archive/refs/tags/v2.0.1.tar.gz"
  sha256 "ebec4e15771fedf8c9bb0c32c0ec4b90b2d24887bc3b8fa054efe7b197f4a4e6"
  license "MIT"
  head "https://github.com/cristianoliveira/funzzy.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "cbd5ecc4307150c42a13e8a70537933089f8e2a2c3d7ad49c5d9f9ebd56ec34e"
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
    system bin/"funzzy", "init"
    assert_match "## Funzzy events file", File.read(testpath/".watch.yaml")

    assert_match version.to_s, shell_output("#{bin}/funzzy --version")
  end
end
