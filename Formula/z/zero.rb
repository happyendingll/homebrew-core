class Zero < Formula
  desc "Terminal coding agent you own"
  homepage "https://zero.gitlawb.com/"
  url "https://github.com/Gitlawb/zero/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "250e6cd090ea4f8fc0c2b42267d7c0563ed54ff00080a810b907f26328f0d38d"
  license "MIT"
  head "https://github.com/Gitlawb/zero.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "89f50c71a67c08f47e186f8bd7e7295211d4a09f0d5b687a4a2d11b66d530da2"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/Gitlawb/zero/internal/cli.version=#{version}]
    system "go", "build", *std_go_args(ldflags:), "./cmd/zero"
  end

  test do
    (testpath/"cmd").mkpath
    (testpath/"cmd/main.go").write <<~GO
      package main

      func main() {}
    GO

    assert_match version.to_s, shell_output("#{bin}/zero --version")

    output = shell_output("#{bin}/zero repo-map --max-files 3 --max-depth 2")
    assert_match "Repo map", output
    assert_match "cmd/main.go", output
  end
end
