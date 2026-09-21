class Mergiraf < Formula
  desc "Syntax-aware git merge driver"
  homepage "https://mergiraf.org"
  url "https://codeberg.org/mergiraf/mergiraf/archive/v0.19.1.tar.gz"
  sha256 "36ccbbd80a3f79bdb23e9e087c9109aeaaed9cc80d85a7722c8db0c0295d107f"
  license "GPL-3.0-only"
  head "https://codeberg.org/mergiraf/mergiraf.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "ce98284ea1bfd17133c305b23e0da6cb7a730839ec24bff4505919a7a9dfe2cc"
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
    assert_match version.to_s, shell_output("#{bin}/mergiraf -V")

    assert_match "YAML (*.yml, *.yaml)", shell_output("#{bin}/mergiraf languages")
  end
end
