class EnpassCli < Formula
  desc "Enpass command-line client"
  homepage "https://github.com/hazcod/enpass-cli"
  url "https://github.com/hazcod/enpass-cli/archive/refs/tags/v1.14.1.tar.gz"
  sha256 "674d0ec15481703962eff2aa69e243ae2cd003048f862344bf925c28d7ed8f3f"
  license "MIT"
  head "https://github.com/hazcod/enpass-cli.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "08048a2bb3b24f508521f76b990fdf89dbe354e4f5e5e0b352883ff14e939703"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", *std_go_args(ldflags: "-X 'main.version=#{version}'"), "./cmd/enpasscli"
    pkgshare.install "test/vault.json", "test/vault.enpassdb"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/enpass-cli version 2>&1")

    # Get test vault files
    mkdir "testvault"
    cp [pkgshare/"vault.json", pkgshare/"vault.enpassdb"], "testvault"
    # Master password for test vault
    ENV["MASTERPW"] = "absolutely-No-clue"
    # Retrieve password for "johndoe" from test vault
    assert_match "noIdeaata11", shell_output("#{bin}/enpass-cli -vault testvault/ pass johndoe").chomp
  end
end
