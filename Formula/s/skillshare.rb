class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.31.0.tar.gz"
  sha256 "4c709ad5fef4244b518725365ee6d0e294117d8b7a4d3f201c4b1499a691d1a8"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "94252e9be611851afd8c35eb9e3867e6e20d06d4897804d27d1093fbbd45aaf6"
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
