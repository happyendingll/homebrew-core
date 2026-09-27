class Upterm < Formula
  desc "Instant terminal sharing"
  homepage "https://upterm.dev"
  url "https://github.com/owenthereal/upterm/archive/refs/tags/v0.32.1.tar.gz"
  sha256 "a7b24a4dcf1d9067231393cb5c5f9002f3a9657ec34322d4e72531b98b6f0c97"
  license "Apache-2.0"
  head "https://github.com/owenthereal/upterm.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "257dbc01de6183cfa90f6726cf6454aef384bcd87096972b2d115d2c78d7cec6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c2e1ffe5df685d4ccff0cc5289a0d9c89e88d323ede40036da3cb8f77e34e3cf"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "552349d6a3b8b3f5b6cc50c431e5566f6c8a80fb3bfc402f80cea09788e46310"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8b97408ec9635440debface5378c6fc2f7c2c19d71ca51488428c44c1834a8c6"
    sha256 cellar: :any,                 x86_64_linux:      "6d90a63c0088518f2c1768735295590216dd653203746b23e085681968ad4dbb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/owenthereal/upterm/internal/version.Version=#{version}
      -X github.com/owenthereal/upterm/internal/version.Date=#{time.iso8601}
    ]

    %w[upterm uptermd].each do |cmd|
      system "go", "build", *std_go_args(output: bin/cmd, ldflags:), "./cmd/#{cmd}"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/upterm version")
    assert_match version.to_s, shell_output("#{bin}/uptermd version")

    output = shell_output("#{bin}/upterm config view")
    assert_match "# Upterm Configuration File", output
    assert_match "server: ssh://uptermd.upterm.dev:22", output
  end
end
