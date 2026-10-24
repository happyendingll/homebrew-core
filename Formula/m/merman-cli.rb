class MermanCli < Formula
  desc "Mermaid.js, but headless, in Rust"
  homepage "https://frankorz.com/merman/"
  url "https://github.com/Latias94/merman/archive/refs/tags/v0.9.2.tar.gz"
  sha256 "423fd38280312c90bcb525ae214998497f935a3a8d3715d1b8bfc555084c076d"
  license any_of: ["MIT", "Apache-2.0"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "d943d0ac43c4fabc2647590674fec8ed2b5881df49bb41233ba0158da7301c6f"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/merman-cli")

    generate_completions_from_executable(bin/"merman-cli", "completion", shells: [:bash, :zsh, :fish, :pwsh])
    man1.install Dir["crates/merman-cli/assets/man/*.1"]
  end

  test do
    mermaid = <<~MMD
      flowchart TD
        A[Start] --> B{Decision}
        B -->|Yes| C[Do thing]
        B -->|No| D[Do other thing]
    MMD
    testdata = testpath/"sample.mmd"
    testdata.write(mermaid)
    assert_match "svg", shell_output("#{bin}/merman-cli render --format svg --output - #{testdata}")
  end
end
