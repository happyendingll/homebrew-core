class Revive < Formula
  desc "Fast, configurable, extensible, flexible, and beautiful linter for Go"
  homepage "https://revive.run"
  url "https://github.com/mgechev/revive.git",
      tag:      "v1.17.1",
      revision: "a13d6ab1804751f8f4f964fb1154d057fc9c9ff6"
  license "MIT"
  head "https://github.com/mgechev/revive.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "331e04c43d5a75d40654d0cb6b7d79098d3b442e07ee68ce55d37ececb6443d2"
  end

  depends_on "go" => [:build, :test]

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/mgechev/revive/cli.commit=#{Utils.git_head}
      -X github.com/mgechev/revive/cli.date=#{time.iso8601}
      -X github.com/mgechev/revive/cli.builtBy=#{tap.user}
    ]
    ldflags << "-X github.com/mgechev/revive/cli.version=#{version}" if build.stable?

    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/revive -version")

    (testpath/"main.go").write <<~GO
      package main

      import "fmt"

      func main() {
        my_string := "Hello from Homebrew"
        fmt.Println(my_string)
      }
    GO

    system "go", "mod", "init", "brewtest"
    output = shell_output("#{bin}/revive main.go")
    assert_match "don't use underscores in Go names", output
  end
end
