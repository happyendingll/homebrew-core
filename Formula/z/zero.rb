class Zero < Formula
  desc "Terminal coding agent you own"
  homepage "https://zero.twigpine.com/"
  url "https://github.com/Twigpine/zero/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "065a2bbcdce5e7fe597247e9a14fc41cb4ff0577461fd73bea72bc889af4d233"
  license "MIT"
  head "https://github.com/Twigpine/zero.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "0ca045bc0c13d98a8ac296693681c4853660b31038368a337f93d42f92c17dac"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/Twigpine/zero/internal/cli.version=#{version}]
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
