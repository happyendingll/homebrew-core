class AwsNuke < Formula
  desc "Nuke a whole AWS account and delete all its resources"
  homepage "https://aws-nuke.ekristen.dev"
  url "https://github.com/ekristen/aws-nuke/archive/refs/tags/v3.67.0.tar.gz"
  sha256 "69ef6d51aba9d1b875c2adae35e321e4030bf098c4bedc8c10822a99af8fc95b"
  license "MIT"
  head "https://github.com/ekristen/aws-nuke.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "a747d95ec2d045d89d01cefccf85d63d575a9531db19658c7f9d634e01d53083"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[-X github.com/ekristen/aws-nuke/v#{version.major}/pkg/common.SUMMARY=#{version}]
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags:)

    pkgshare.install "pkg/config"

    generate_completions_from_executable(bin/"aws-nuke", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aws-nuke --version")
    assert_match "InvalidClientTokenId", shell_output(
      "#{bin}/aws-nuke run --config #{pkgshare}/config/testdata/example.yaml \
      --access-key-id fake --secret-access-key fake 2>&1",
      1,
    )
    assert_match "IAMUser", shell_output("#{bin}/aws-nuke resource-types")
  end
end
