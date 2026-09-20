class Goimports < Formula
  desc "Go formatter that additionally inserts import statements"
  homepage "https://pkg.go.dev/golang.org/x/tools/cmd/goimports"
  url "https://github.com/golang/tools/archive/refs/tags/v0.50.0.tar.gz"
  sha256 "22d397e6b0a3040aae4fbc6fccb7738b31575a86b754b8604892353f195368a2"
  license "BSD-3-Clause"
  head "https://github.com/golang/tools.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "fcc57edaa30bb445aec93b6f3ebf0aba4f4643104fe3bca1d630ff18091b9f48"
  end

  depends_on "go"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    chdir "cmd/goimports" do
      system "go", "build", *std_go_args
    end
  end

  test do
    (testpath/"main.go").write <<~GO
      package main

      func main() {
        fmt.Println("hello")
      }
    GO

    assert_match(/\+import "fmt"/, shell_output("#{bin}/goimports -d #{testpath}/main.go"))
  end
end
