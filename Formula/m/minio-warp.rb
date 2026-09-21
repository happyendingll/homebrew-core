class MinioWarp < Formula
  desc "S3 benchmarking tool"
  homepage "https://github.com/minio/warp"
  url "https://github.com/minio/warp/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "5f0f8cbffccb4685cb5d1b191337369becf8fdd65277b68b189eb1e9eba6647b"
  license "AGPL-3.0-or-later"
  head "https://github.com/minio/warp.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "3f8ee8d11e8795844ff7725ea6d974d6315b1d2c08bcb56ba3b87c2128e9920f"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/minio/warp/pkg.ReleaseTag=v#{version}
      -X github.com/minio/warp/pkg.CommitID=#{tap.user}
      -X github.com/minio/warp/pkg.Version=#{version}
      -X github.com/minio/warp/pkg.ReleaseTime=#{time.iso8601}
    ]

    system "go", "build", *std_go_args(ldflags:, output: bin/"warp")
  end

  test do
    output = shell_output("#{bin}/warp list --no-color --quiet 2>&1", 1)
    assert_match "warp: <ERROR> Error preparing server", output

    assert_match version.to_s, shell_output("#{bin}/warp --version")
  end
end
