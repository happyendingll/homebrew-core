class Circleci < Formula
  desc "Official command-line tool for CircleCI"
  homepage "https://cli.circleci.com"
  # Updates should be pushed no more frequently than once per week.
  url "https://github.com/CircleCI-Public/circleci-cli.git",
      tag:      "v1.0.51753",
      revision: "f411e911104ab12d998a862001df1b781001a9ee"
  license "MIT"
  head "https://github.com/CircleCI-Public/circleci-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c25ac53dfe36f7f076d8b7086702961890ac3312919fa6ffa37c80b7ed4007b5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4b50cf6e3f801db5ed0da28e04f901a42df51edd06f793143744b93e325801fa"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c04275761aa58055712527738bcf5cf5a44bf5a55867960066f1aba8354f6e2c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "935639eb3572dcd9b0323d80a390cd52f1a1d8d0faf192045600516dca154b33"
    sha256 cellar: :any,                 x86_64_linux:      "1e33385db6f43abaf1a26e8d9c2ab34a094e85f22c01d1f282608cf214604251"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

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
