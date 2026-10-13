class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.25.6.tar.gz"
  sha256 "7962785687bb134c2b05cb583c708fd66637d67b77156ea530f48825dace92a2"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a5426bb27de16b8a8a393c1f050af9f95e2976c0e001743aa805a978b40a7c34"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a5426bb27de16b8a8a393c1f050af9f95e2976c0e001743aa805a978b40a7c34"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a5426bb27de16b8a8a393c1f050af9f95e2976c0e001743aa805a978b40a7c34"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d512028f6ec7a1291beb045b6e9199c8077093fb23749134f74d79e5fe1de8b3"
    sha256 cellar: :any,                 x86_64_linux:      "a335e605d4a98325d8c964dbf96ae84c3d44eba1f84432ca79f9733e4ac7574b"
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
