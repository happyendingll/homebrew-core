class Circleci < Formula
  desc "Official command-line tool for CircleCI"
  homepage "https://cli.circleci.com"
  # Updates should be pushed no more frequently than once per week.
  url "https://github.com/CircleCI-Public/circleci-cli.git",
      tag:      "v1.0.51242",
      revision: "66f6139dab3245e81069eee4150f356cd02aaae6"
  license "MIT"
  head "https://github.com/CircleCI-Public/circleci-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "30512336b00a797eb0870b8ff91b7150ee21b3bf699c9a294a5845de60855e7d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bc538cacd67ce1aa04b93b5156c151bb7d6ae33cc0b4c954b103ad7bb9e555ec"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2e4bc966050cbea7fdcac1e313607b828f0fb767c474230b26620fecb2edced2"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "142d547f57d158f0de5aaff68dd29ac3ea52cc4bc78345724e00fe5cfda78190"
    sha256 cellar: :any,                 x86_64_linux:      "aac78edd64ddce69fb1e5e31451928775d4f8abbad334a1bd32584277ab37c80"
  end

  depends_on "go" => :build

  def install
    ldflags = "-X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/circleci"

    generate_completions_from_executable(bin/"circleci", "completion")
    system bin/"circleci", "man", "--output", man1/"circleci.1"
  end

  test do
    ENV["DO_NOT_TRACK"] = "1"
    # assert basic script execution
    assert_match(/^circleci #{version} \(\h{12}\)$/, shell_output("#{bin}/circleci version").strip)
    (testpath/".circleci.yml").write("{version: 2.1}")
    output = shell_output("#{bin}/circleci config pack #{testpath}/.circleci.yml")
    assert_match "version: 2.1", output
  end
end
