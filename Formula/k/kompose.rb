class Kompose < Formula
  desc "Tool to move from `docker-compose` to Kubernetes"
  homepage "https://kompose.io/"
  url "https://github.com/kubernetes/kompose/archive/refs/tags/v1.39.0.tar.gz"
  sha256 "10520140fb3854fc19471c32d994e4479850e2fa2e44f88e07d6877872c00baf"
  license "Apache-2.0"
  head "https://github.com/kubernetes/kompose.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "75dbe27c591cffd9c1df4c38bb7847233ea8a1df3dbc2688f23837a86209c963"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    system "go", "build", *std_go_args

    generate_completions_from_executable(bin/"kompose", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kompose version")
  end
end
