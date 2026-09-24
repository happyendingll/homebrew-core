class Sofka < Formula
  desc "Kubernetes TUI, reimagined in Rust"
  homepage "https://github.com/nklmilojevic/sofka"
  url "https://github.com/nklmilojevic/sofka/archive/refs/tags/v0.28.6.tar.gz"
  sha256 "42a4c9e6c9bd1cf20a7d90ad8c083604038a7b5198eb1a1a89f27f8a72c64324"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "01ed8d84a62b8d739502d08ded3ba94f49ce44686c5d324b0285b6c16ac1babc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b49884ccb465e61bcbb29455f3dcde5225bbb64bde684790de6fd5df1f109419"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ad5bfc6a55c369333b9b63a269d5129a430cb2345fc9c402c89140b86490fd61"
    sha256 cellar: :any,                 arm64_linux:       "fe54b551bc77dd0897768641aff39a4fa06ab548c14d7a88c1e9833f3f5c3288"
    sha256 cellar: :any,                 x86_64_linux:      "94ebfdbf00b40ee2f9d565b518a52955ec3d30c7382257a8f6864cbbc7a3da18"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"sofka", "completion")
  end

  test do
    assert_equal "sofka #{version}\n", shell_output("#{bin}/sofka --version")
    assert_match "failed to read kubeconfig", shell_output("#{bin}/sofka --check 2>&1", 1)
  end
end
