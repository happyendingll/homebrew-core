class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.21.5.tar.gz"
  sha256 "cd9c72e9cdb2edd1b8e41bf645acbbfac5e7f8cfcb016530e8a1ffb171bfbcae"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "cecfe5521ae05a09e9580a30132982dcbb0d468897c01f710f49be4b655b07c1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "cecfe5521ae05a09e9580a30132982dcbb0d468897c01f710f49be4b655b07c1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "cecfe5521ae05a09e9580a30132982dcbb0d468897c01f710f49be4b655b07c1"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "76a2900c74ccf038aebbae5b7769ff1ff705eac209859ed219c1ea6f069849dd"
    sha256 cellar: :any,                 x86_64_linux:      "9e0ab8a3bbb0ab852d9149d4c5163971d545abd5136287dc997260f14f6bfd0c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Avoid building web UI
    ui_path = "internal/server/dist"
    mkdir_p ui_path
    (buildpath/"#{ui_path}/index.html").write "<!DOCTYPE html><html><body><h1>UI not built</h1></body></html>"

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/skillshare"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/skillshare version")

    assert_match "config not found", shell_output("#{bin}/skillshare sync 2>&1", 1)
  end
end
