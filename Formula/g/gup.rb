class Gup < Formula
  desc "Update binaries installed by go install"
  homepage "https://github.com/nao1215/gup"
  url "https://github.com/nao1215/gup/archive/refs/tags/v1.10.5.tar.gz"
  sha256 "72d6db19284a9c0f5ccbbcceb24b655e6e1c5feb93fcd82edaa2b31eff0e02da"
  license "Apache-2.0"
  head "https://github.com/nao1215/gup.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "d705d930908177413c1272deef4512bf961d65498f009270931a705dff3b16a5"
  end

  depends_on "go"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/nao1215/gup/internal/cmdinfo.Version=v#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"gup", shell_parameter_format: :cobra)

    ENV["MANPATH"] = man1.mkpath
    system bin/"gup", "man"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gup version")

    ENV["GOBIN"] = testpath/"bin"
    (testpath/"bin").mkpath

    (testpath/"hello").mkpath
    (testpath/"hello/go.mod").write <<~MOD
      module example.com/hello
      go 1.22
    MOD
    (testpath/"hello/main.go").write <<~GO
      package main
      import "fmt"
      func main() { fmt.Println("hello") }
    GO

    cd testpath/"hello" do
      system "go", "install", "."
    end

    assert_match "hello: example.com/hello", shell_output("#{bin}/gup list")
    system bin/"gup", "remove", "--force", "hello"
    refute_path_exists testpath/"bin/hello"
  end
end
