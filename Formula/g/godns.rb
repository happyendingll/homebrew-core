class Godns < Formula
  desc "Dynamic DNS client with multiple providers support"
  homepage "https://github.com/TimothyYe/godns"
  url "https://github.com/TimothyYe/godns/archive/refs/tags/v3.4.6.tar.gz"
  sha256 "ccec55e12aa1d22655e1c3894189902d30d7ac1a42f594dd25b5681c5dffb65d"
  license "Apache-2.0"
  head "https://github.com/TimothyYe/godns.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "e17cd7ee17b690717722ed60496b68110f267d2ed5ff40da329f13325e8beadb"
  end

  depends_on "go" => :build

  resource "web" do
    url "https://github.com/TimothyYe/godns/releases/download/v3.4.6/godns-web-v3.4.6.zip"
    sha256 "d6f0d0d1b50e1cd1957b03e3e1f40e2224f617cd641c7ed04d2d0f9a62628cde"

    livecheck do
      formula :parent
    end
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    resource("web").stage(buildpath/"internal/server/out")
    system "go", "build", *std_go_args(ldflags: "-X main.Version=v#{version}"), "./cmd/godns"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/godns -h")

    (testpath/"config.json").write "{}"
    output = shell_output("#{bin}/godns -c #{testpath}/config.json 2>&1", 1)
    assert_match "Invalid settings", output
  end
end
