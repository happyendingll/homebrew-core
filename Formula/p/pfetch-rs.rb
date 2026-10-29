class PfetchRs < Formula
  desc "Pretty system information tool written in Rust"
  homepage "https://github.com/Gobidev/pfetch-rs"
  url "https://github.com/Gobidev/pfetch-rs/archive/refs/tags/v3.1.1.tar.gz"
  sha256 "13730b58a1fe20acfe32e17056f1d48a12a1ea7209c9c28507d21ccb36144466"
  license "MIT"
  head "https://github.com/Gobidev/pfetch-rs.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "dc633b3337042fb7eab8482d29649d6b1887431fe4247d9a270c0c1d78beb02f"
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
    assert_match "uptime", shell_output("#{bin}/pfetch")
  end
end
