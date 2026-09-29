class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.21.17.tar.gz"
  sha256 "2d32366720b1683973384d3c401cd71bdd22dca966abb699f69edbba23f6a907"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "99a8e7a8aa8292ff2beb9b21f5b06b59b81cc89484226a4c497b86449ab66afa"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "99a8e7a8aa8292ff2beb9b21f5b06b59b81cc89484226a4c497b86449ab66afa"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "99a8e7a8aa8292ff2beb9b21f5b06b59b81cc89484226a4c497b86449ab66afa"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "08ff95ef1fc50943b480b59854688b0bf15236fb81b4840a16e0d4f99e34f5c2"
    sha256 cellar: :any,                 x86_64_linux:      "05c00988e3cf7cc510a6ebdbf9dad3bd1c97fb84abe9c69a0e332fe75b89c28c"
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
