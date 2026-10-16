class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.69.0.tar.gz"
  sha256 "9c8b24b4de0fef53e8ed267867171e4421300bed2aff35b79321ab72f1deb3aa"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "21676bc21be05a7de5f98a64b4a957113334ca8afa9b55fd8b71bcfec799046a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3e643c379bb5ee4cc5f2c73c33c9023a0774626668e28a128492f7f493cc7017"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7bbf0f08e6f702a1982c64be84c2e1a027d1e580d758a98d2fd6b4a77caf3563"
    sha256 cellar: :any,                 arm64_linux:       "21d41c5812a5f73af66f5b6806816c48b9002745480eb37ab6ff5bc50adce71a"
    sha256 cellar: :any,                 x86_64_linux:      "3e718d177e113310d861890414fbe93f289ebd320502c7db7c3c1324db52e7d1"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"railway", "completion")
  end

  test do
    output = shell_output("#{bin}/railway init 2>&1", 1).chomp
    assert_match "Unauthorized. Please login with `railway login`", output

    assert_equal "railway #{version}", shell_output("#{bin}/railway --version").strip
  end
end
