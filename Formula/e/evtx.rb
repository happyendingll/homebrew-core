class Evtx < Formula
  desc "Windows XML Event Log parser"
  homepage "https://github.com/omerbenamram/evtx"
  url "https://github.com/omerbenamram/evtx/archive/refs/tags/v0.15.1.tar.gz"
  sha256 "0b62f517a580f6afe30e9c6ad543e0e9d2763e47fc5d724a508526aa49e8c840"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/omerbenamram/evtx.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "26aa0b954aec57f071aa05c1fd7a29b0574e14bac1cf85b35bbe8687958249b5"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    pkgshare.install "samples"
  end

  test do
    cp pkgshare/"samples/issue_201.evtx", testpath
    assert_match "Remote-ManagementShell-Unknown",
      shell_output("#{bin}/evtx_dump #{pkgshare}/samples/issue_201.evtx")

    assert_match "EVTX Parser #{version}", shell_output("#{bin}/evtx_dump --version")
  end
end
