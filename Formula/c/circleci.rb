class Circleci < Formula
  desc "Official command-line tool for CircleCI"
  homepage "https://cli.circleci.com"
  # Updates should be pushed no more frequently than once per week.
  url "https://github.com/CircleCI-Public/circleci-cli.git",
      tag:      "v1.0.49959",
      revision: "6b297bc707d5c54c5a625d20e6658580df1139c3"
  license "MIT"
  head "https://github.com/CircleCI-Public/circleci-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4b720e5ae0e5dfe1479815f83ea2f5cf4b741c2343ca2acbca7a93049d73ba83"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d9981fb3766fe6028fad1529f5bfe94434d0fdfa308a4789e96ce455848aabcd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "de4c57828ce29519a1c415fbb95370a2727a3e002bc9812e8fe7283ed4868230"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "08c8355599a0e44ee933ba358385a7fec346fa0b615c64b447ef218d78bd7cff"
    sha256 cellar: :any,                 x86_64_linux:  "cae74fcd6ff13f7c05f68a2791bfc2c2d97c2e094dd9707ea08f375b91e089bc"
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
