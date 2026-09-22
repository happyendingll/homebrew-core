class PfetchRs < Formula
  desc "Pretty system information tool written in Rust"
  homepage "https://github.com/Gobidev/pfetch-rs"
  url "https://github.com/Gobidev/pfetch-rs/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "571d339ad29561bdc510c09f3cac2bb0b8dc619b3528db68915e5927e70c5988"
  license "MIT"
  head "https://github.com/Gobidev/pfetch-rs.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "3f78152d8c06c57db739f6c66a1b35919cda5ec808ca5f7f51b9cdad0ad374ef"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "uptime", shell_output("#{bin}/pfetch")
  end
end
