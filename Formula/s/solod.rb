class Solod < Formula
  desc "Strict subset of Go with transpiler that translates to regular C"
  homepage "https://solod.dev/"
  url "https://github.com/solod-dev/solod.git",
    tag:      "v0.4.0",
    revision: "e84cd34481f735ed30d03ef69eedd5c371c21532"
  license "BSD-3-Clause"
  head "https://github.com/solod-dev/solod.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "d7eafd3c72d417fe46592be2bdfab3f26ff87957e5d066fa4462102b7bf8a04b"
  end

  depends_on "go" => [:build, :test]

  conflicts_with "so", because: "both install `so` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(output: bin/"so"), "./cmd/so"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/so version")

    (testpath/"main.go").write <<~GO
      package main

      func main() {
      	println("Hello, World!")
      }
    GO

    system "go", "mod", "init", "testproject"

    assert_match "Hello, World!", shell_output("#{bin}/so run .")

    system bin/"so", "translate", "."
    assert_path_exists testpath/"main.c"
    assert_match "int main(void)", (testpath/"main.c").read
    assert_match "\"Hello, World!\"", (testpath/"main.c").read

    system ENV.cc, "-o", "main", "main.c", "so/builtin/builtin.c"
    assert_match "Hello, World!", shell_output("./main")
  end
end
