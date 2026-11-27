class VolcanoCli < Formula
  desc "CLI for Volcano, Cloud Native Batch System"
  homepage "https://volcano.sh"
  url "https://github.com/volcano-sh/volcano/archive/refs/tags/v1.16.1.tar.gz"
  sha256 "80326f033d3713904ac5076473106a51f46a510a0ab08739ca21127110717daa"
  license "Apache-2.0"
  head "https://github.com/volcano-sh/volcano.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "74881c3ed6831883d2b5251ee51fe1dd59f66cd6e5b2da15a857ab0a8068a22e"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X volcano.sh/volcano/pkg/version.GitSHA=#{tap.user}
      -X volcano.sh/volcano/pkg/version.Built=#{time.iso8601}
      -X volcano.sh/volcano/pkg/version.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"vcctl"), "./cmd/cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vcctl version")

    output = shell_output("#{bin}/vcctl queue list 2>&1", 255)
    assert_match "Failed to list queue", output
  end
end
