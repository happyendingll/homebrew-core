class AwsNuke < Formula
  desc "Nuke a whole AWS account and delete all its resources"
  homepage "https://aws-nuke.ekristen.dev"
  url "https://github.com/ekristen/aws-nuke/archive/refs/tags/v3.68.3.tar.gz"
  sha256 "2f06b307aa1addccf9231f0fd1f394c63507a8c7438e8113a91386066be0d6aa"
  license "MIT"
  head "https://github.com/ekristen/aws-nuke.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "d10d81cd86016908bd6b63ebb26d9e55a6c70d6d4b8c1004d0301132d0a39602"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

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
