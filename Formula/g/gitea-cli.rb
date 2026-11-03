class GiteaCli < Formula
  desc "Official command-line tool for Gitea"
  homepage "https://gitea.com/gitea/cli"
  url "https://gitea.com/gitea/cli/archive/v1.0.0.tar.gz"
  sha256 "587669217030aabf4f1c344187832dbd1c41cf849fc4525a1cdbc11a11390c84"
  license "MIT"
  head "https://gitea.com/gitea/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "eec46e8233cd3c907f5014093fdf70c1cfce46ca983d26a92230bfd49795e3d6"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X gitea.dev/cli/internal/version.Version=#{version}]
    system "go", "build", *std_go_args(ldflags:, output: bin/"gt"), "./cmd/gt"
    generate_completions_from_executable(bin/"gt", shell_parameter_format: :cobra)
    (man1/"gt.1").write Utils.safe_popen_read(bin/"gt", "man")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gt --version")
    ENV["GITEA_CLI_CONFIG_DIR"] = testpath
    assert_match (testpath/"config.yml").to_s, shell_output("#{bin}/gt config path")
  end
end
