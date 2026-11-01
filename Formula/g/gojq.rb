class Gojq < Formula
  desc "Pure Go implementation of jq"
  homepage "https://github.com/itchyny/gojq"
  url "https://github.com/itchyny/gojq.git",
      tag:      "v0.12.20",
      revision: "e7c14eca0339b4a122f9b293a114e267f8699f49"
  license "MIT"
  head "https://github.com/itchyny/gojq.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "f8a76f9c019e8d1d24055322aa302f59241d1808114664298268219c3288f1bf"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    revision = Utils.git_short_head
    ldflags = %W[-X github.com/itchyny/gojq/cli.revision=#{revision}]
    system "go", "build", *std_go_args(ldflags:), "./cmd/gojq"
    zsh_completion.install "_gojq"
  end

  test do
    assert_equal "2\n", pipe_output("#{bin}/gojq .bar", '{"foo":1, "bar":2}')
  end
end
