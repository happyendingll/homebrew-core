class BitbucketCli < Formula
  desc "CLI for Bitbucket Cloud and Data Center"
  homepage "https://github.com/avivsinai/bitbucket-cli"
  url "https://github.com/avivsinai/bitbucket-cli/archive/refs/tags/v0.35.1.tar.gz"
  sha256 "a04dfc50e88f38987c81c8bff2a7000e3b8ac639cc57c3f7eb0b40d46a6742b0"
  license "MIT"
  head "https://github.com/avivsinai/bitbucket-cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "9adad03aa1258b72c5844e748057c4aa6343a6ac8de0a611a54c1bfbe6edd9cf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ae8b2c1d906f95ed857a89999e02a19206342887f68cefbe3ef0e7d3045924d2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ca00f07636411803924750f84e9c995bd068de2040b1240f777444611b2a4bd6"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "57e5699146d29c9494465aeae3433efe99ef62847bffa7ee197b3b3a7b62d755"
    sha256 cellar: :any,                 x86_64_linux:      "76b30773d6f12ef317bb1d4c9ee61d1acbb6775fef5200f0a175eb5bfe9e6ffb"
  end

  depends_on "go" => :build

  conflicts_with "bkt", because: "both install `bkt` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/avivsinai/bitbucket-cli/internal/build.versionFromLdflags=#{version}
      -X github.com/avivsinai/bitbucket-cli/internal/build.dateFromLdflags=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"bkt"), "./cmd/bkt"
    generate_completions_from_executable(bin/"bkt", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bkt --version")
    assert_match "No contexts configured", shell_output("#{bin}/bkt context list")
    assert_match "no active context", shell_output("#{bin}/bkt repo list 2>&1", 1)
  end
end
