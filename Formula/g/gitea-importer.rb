class GiteaImporter < Formula
  desc "CLI to migrate repositories from GitHub, GitLab and Gitea into Gitea"
  homepage "https://gitea.com/gitea/importer"
  url "https://gitea.com/gitea/importer/archive/v0.4.0.tar.gz"
  sha256 "b16d6092e62eaf1dcbc5f6aa6424b0cefc979bfa7d706f393b032cebf5c1e443"
  license "MIT"
  head "https://gitea.com/gitea/importer.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "9ff43e084272c1e611da8bcaff610109ed1e05e18c8c1ca329f93f0cc9e8600c"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X gitea.com/gitea/importer/internal/app.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gitea-importer version")

    output = shell_output("#{bin}/gitea-importer scan --source-type gitea --source-repos foo/bar 2>&1", 1)
    assert_match "gitea provider requires a token", output

    url = "http://127.0.0.1:#{free_port}"
    args = %W[--source-type gitea --source-url #{url} --source-auth pat://test --source-repos foo/bar]
    output = shell_output("#{bin}/gitea-importer scan #{args.join(" ")} 2>&1", 1)
    assert_match "Get \"#{url}/api/v1/", output
  end
end
