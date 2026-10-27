class GiteaCli < Formula
  desc "Official command-line tool for Gitea"
  homepage "https://gitea.com/gitea/cli"
  url "https://gitea.com/gitea/cli/archive/v0.2.0.tar.gz"
  sha256 "a5a9f8b7efdfc1404d8ba4a8d0228a498f6883ee415e44df9990178d4b2c76c3"
  license "MIT"
  head "https://gitea.com/gitea/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "325027d5bef613a92ea2dcc92a15ef55eb6db64d163a16ee2bba0d3445ea407b"
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
