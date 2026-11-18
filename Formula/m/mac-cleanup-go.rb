class MacCleanupGo < Formula
  desc "TUI macOS cleaner that scans caches/logs and lets you select what to delete"
  homepage "https://github.com/2ykwang/mac-cleanup-go"
  url "https://github.com/2ykwang/mac-cleanup-go/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "4d939cc1c4d364fa66d3a27189b670d97a89040373a67ca84a9e3c9efb069a27"
  license "MIT"
  head "https://github.com/2ykwang/mac-cleanup-go.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e55092f825fccfd5dea28c919ddf5fa839514351d33db2a299dfecfa7194bf3a"
  end

  depends_on "go" => :build
  depends_on :macos

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", output: bin/"mac-cleanup")
  end

  test do
    # mac-cleanup-go is a TUI application
    assert_match version.to_s, shell_output("#{bin}/mac-cleanup --version")
  end
end
