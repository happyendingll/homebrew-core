class Godns < Formula
  desc "Dynamic DNS client with multiple providers support"
  homepage "https://github.com/TimothyYe/godns"
  url "https://github.com/TimothyYe/godns/archive/refs/tags/v3.4.4.tar.gz"
  sha256 "77601cc500a45cb70e2f4ff5262d493ab298fb8d29b6c5a462ac776ddbd4f875"
  license "Apache-2.0"
  head "https://github.com/TimothyYe/godns.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "85bd3a3a963613ccc9bb879d91d2094a816ea496e90a2e5a52ba80a1182b3b90"
  end

  depends_on "go" => :build

  resource "web" do
    url "https://github.com/TimothyYe/godns/releases/download/v3.4.4/godns-web-v3.4.4.zip"
    sha256 "9c3f32a163b9783fffb67bed6d38d8b8a9d14bc853998f19cb39e9416e4ebf33"

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
