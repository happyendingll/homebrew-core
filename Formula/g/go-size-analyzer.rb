class GoSizeAnalyzer < Formula
  desc "Analyzing the dependencies in compiled Golang binaries"
  homepage "https://gsa.zxilly.dev/"
  url "https://github.com/Zxilly/go-size-analyzer/archive/refs/tags/v1.14.1.tar.gz"
  sha256 "c33d0ff8c5c5fd37cb30d8d6a963fe07a20f13cfe4bf2cf3832af93f421eee11"
  license "AGPL-3.0-only"
  head "https://github.com/Zxilly/go-size-analyzer.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "6810b39209cfb45d276aca1b047009c06e79c80e417707ef8d211d73657fb90f"
  end

  depends_on "go" => [:build, :test]
  depends_on "node" => :build
  depends_on "pnpm@10" => :build # frozen build (default on CI) needs upstream changes for pnpm 11

  conflicts_with "gwenhywfar", because: "both install `gsa` binaries"

  deny_network_access!

  def fetch
    # Prevent pnpm from downloading another copy due to `packageManager` feature
    odie "Switch to `pnpm with current`!" if deps.map(&:name).exclude?("pnpm@10")
    (buildpath/"ui/pnpm-workspace.yaml").write <<~YAML
      managePackageManagerVersions: false
    YAML

    system "pnpm", "--dir", "ui", "fetch"
    system "go", "mod", "download"
  end

  def install
    system "pnpm", "--offline", "--dir", "ui", "install", "--frozen-lockfile"
    system "pnpm", "--dir", "ui", "build:ui"

    mv "ui/dist/webui/index.html", "internal/webui/index.html"

    # Set experimental feature for go
    ENV["GOEXPERIMENT"] = "jsonv2"

    ldflags = %W[
      -X github.com/Zxilly/go-size-analyzer.version=#{version}
      -X github.com/Zxilly/go-size-analyzer.buildDate=#{time.iso8601}
      -X github.com/Zxilly/go-size-analyzer.dirtyBuild=false
    ]

    system "go", "build", *std_go_args(ldflags:, tags: "embed", output: bin/"gsa"), "./cmd/gsa"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gsa --version")

    (testpath/"hello.go").write <<~GO
      package main

      func main() {
        println("Hello, World")
      }
    GO

    system "go", "build", testpath/"hello.go"

    output = shell_output("#{bin}/gsa #{testpath}/hello 2>&1")
    assert_match "runtime", output
    assert_match "main", output
  end
end
