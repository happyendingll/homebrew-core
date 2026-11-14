class Jjui < Formula
  desc "TUI for interacting with the Jujutsu version control system"
  homepage "https://idursun.github.io/jjui/"
  url "https://github.com/idursun/jjui/archive/refs/tags/v0.10.13.tar.gz"
  sha256 "f1f68ab9431b1ddb2bd24db68735397167d590d6fcc66035056918b97b283089"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "e10bb7c30f057f49a147facc7b7877ac1e10416f341fb9051b5e418422aa444e"
  end

  depends_on "go" => :build
  depends_on "jj"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}"), "./cmd/jjui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jjui -version")
    assert_match "There is no jj repo in", shell_output("#{bin}/jjui 2>&1", 1)
  end
end
