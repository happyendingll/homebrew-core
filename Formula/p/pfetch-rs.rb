class PfetchRs < Formula
  desc "Pretty system information tool written in Rust"
  homepage "https://github.com/Gobidev/pfetch-rs"
  url "https://github.com/Gobidev/pfetch-rs/archive/refs/tags/v3.0.2.tar.gz"
  sha256 "620936d3c485a549d22a26633f60aa1cda1ce2745b90ffc634ddb4e1137ffc07"
  license "MIT"
  head "https://github.com/Gobidev/pfetch-rs.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "68619096f4fe3ddbcff206ae0f7c64cd38175082b258d31e3e67ae1bb17389a6"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "uptime", shell_output("#{bin}/pfetch")
  end
end
