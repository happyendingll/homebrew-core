class AtomgitCli < Formula
  desc "Command-line interface for AtomGit"
  homepage "https://atomgit.com/hust-open-atom-club/atomgit-cli"
  url "https://raw.atomgit.com/hust-open-atom-club/atomgit-cli/archive/refs/heads/v0.7.4.tar.gz"
  sha256 "226a5d26c566360456fd87ad9331570d1b0212dc0b8f5fd2ec85745dcf107611"
  license "MulanPSL-2.0"
  head "https://atomgit.com/hust-open-atom-club/atomgit-cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "3ad3132e21e7a1b6f2a2a4d9f4b73c8ee944b00c1da4b671d1f99b4501e9b560"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X atomgit.com/hust-open-atom-club/atomgit-cli/internal/version.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"ag-cli"), "./cmd/ag-cli"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ag-cli version")

    system bin/"ag-cli", "alias", "set", "rv", "repo", "view"
    aliases = shell_output("#{bin}/ag-cli alias list")
    assert_match "rv", aliases
    assert_match "repo view", aliases
  end
end
