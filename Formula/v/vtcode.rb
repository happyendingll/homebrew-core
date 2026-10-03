class Vtcode < Formula
  desc "CLI Semantic Coding Agent"
  homepage "https://vinhnx.github.io"
  url "https://static.crates.io/crates/vtcode/vtcode-0.171.5.crate"
  sha256 "1f77cb6962d556e5302b2b0870fb6abd505c41d350cec2a766318aa4d7b59082"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/vinhnx/vtcode.git", branch: "main"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "07b43f1544a155493da2f9f1ee5abdaa75bfdd60bd3a09febd83fd5fab457725"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bb6a7323bc6fc2fefad65a7c23a43f8b0a130a46ab17fd897c47d7e7b33c5ad6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b49f78b6486a160646a08b375ffd0e58b06383ac6dc15ee8017743bdcb0d7c78"
    sha256 cellar: :any,                 arm64_linux:       "873521c3ac03e6b89bd0ee0946cbea418d231c703fcf32ddbbf44bd4ae24396c"
    sha256 cellar: :any,                 x86_64_linux:      "aa38d50ec567a2f999463ce149af2d558d782bdce8cc0b5130b42ac1967520fb"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "ripgrep"

  on_linux do
    depends_on "openssl@4" => :build
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.linux?
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtcode --version")

    ENV["OPENAI_API_KEY"] = "test"
    output = shell_output("#{bin}/vtcode models list --provider openai")
    assert_match "OPENAI", output
  end
end
