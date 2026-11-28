class GitSync < Formula
  desc "Clones a git repository and keeps it synchronized with the upstream"
  homepage "https://github.com/kubernetes/git-sync"
  url "https://github.com/kubernetes/git-sync/archive/refs/tags/v4.8.1.tar.gz"
  sha256 "a7fb384fcc826fa0f4f1ef47004ad00ed66eb8814d4656e8b73b90534ebc629b"
  license "Apache-2.0"
  head "https://github.com/kubernetes/git-sync.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "f007dc2d41b3e518741bd540ea27751f9d77dfaa57688b9c5ab8876381b4e442"
  end

  depends_on "go" => :build

  depends_on "coreutils"
  depends_on "git" # needs `git config list` (git 2.46+)

  conflicts_with "git-extras", because: "both install `git-sync` binaries"

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X k8s.io/git-sync/pkg/version.VERSION=v#{version}]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    expected_output = "Could not read from remote repository"
    assert_match expected_output, shell_output("#{bin}/#{name} --repo=127.0.0.1/x --root=/tmp/x 2>&1", 1)

    assert_match version.to_s, shell_output("#{bin}/#{name} --version")
  end
end
