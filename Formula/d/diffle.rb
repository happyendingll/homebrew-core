class Diffle < Formula
  desc "Keyboard-first diff viewer with LSP support and GitHub integration"
  homepage "https://github.com/moritzwilksch/diffle"
  url "https://github.com/moritzwilksch/diffle/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "1652d12968d363330be4f9dcda222e88ff98ea0031076b48e57c2375d0135b7b"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "727b040f2a709f40385d8ea5098339493d8ba0ad677cf250eddfbf3e0b1bf7a9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "175a9726b7d119740dd3b117676b12358966ed754e14e21f65ddc7b2a3344914"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6b86893b1c13b9cf6baa23a44fabf220f7d21185d0dcd0127a41f6341d5a51c9"
    sha256 cellar: :any,                 arm64_linux:       "ada4349b8329b405a9a1042d173615b4c0f3a82ee41c5149a02ff3ca5060477c"
    sha256 cellar: :any,                 x86_64_linux:      "fb8a28157f71029ebb3a3ffca1f2c08119660ca85fbf834c543184b99a993853"
  end

  depends_on "node" => :build
  depends_on "rust" => :build

  allow_network_access! :test

  def fetch
    system "npm", "ci", "--ignore-scripts", *std_npm_args(prefix: false)
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "npm", "run", "build"
    system "cargo", "install", *std_cargo_args(path: "crates/diffle")

    generate_completions_from_executable(bin/"diffle", "completion", "--shell")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/diffle --version")

    system "git", "init", "--initial-branch=main"
    system "git", "config", "user.name", "BrewTestBot"
    system "git", "config", "user.email", "BrewTestBot@test.com"
    (testpath/"hello.txt").write "hello\n"
    system "git", "add", "hello.txt"
    system "git", "commit", "-m", "initial"
    (testpath/"hello.txt").append_lines "world"

    port = free_port
    pid = spawn bin/"diffle", "working", "--port", port.to_s, "--no-open", "--no-lsp", "--no-watch", "--keep-alive"
    begin
      sleep 5
      assert_match "<html", shell_output("curl -s http://127.0.0.1:#{port}/")
      assert_match "+world", shell_output("curl -s http://127.0.0.1:#{port}/api/patch")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
