class B4n < Formula
  desc "Terminal user interface (TUI) for Kubernetes API written in Rust"
  homepage "https://github.com/fioletoven/b4n"
  url "https://github.com/fioletoven/b4n/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "990f7188ebff2d68de8297a59e562ecb738f3245c368a63c3d57f5ddc4b5cf57"
  license "MIT"
  head "https://github.com/fioletoven/b4n.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "5d49fc3a72f65d562ad6ebf0bd0e60a7104360aea2fed4bf5e2ab5a7ea34d184"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # a cli will complain on incorrectly configured kube context or config file passed
    assert_match "Error: Kube context 'none' not found in configuration.",
                 shell_output("#{bin}/b4n --kube-config=/dev/null --context=none 2>&1", 1)
  end
end
