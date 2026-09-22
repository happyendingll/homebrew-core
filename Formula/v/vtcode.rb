class Vtcode < Formula
  desc "CLI Semantic Coding Agent"
  homepage "https://vinhnx.github.io"
  url "https://static.crates.io/crates/vtcode/vtcode-0.166.0.crate"
  sha256 "677de8b2bf4fb511e39eb22bd6dda6af1b33a9a831bbab6c7a78fef3d901e96b"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/vinhnx/vtcode.git", branch: "main"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "837639cbec0fb7e511c51776ad616290e0b8b7ca27441b48287cd5a50cdb39d0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "dd0c9ccaa824adc3f5523ed3d5b903f04bbffbca1dae213f02671288af08049f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "12451c32ecab00e6462608cd6597f73b6888964ac44066ee1f8f95f482bd3225"
    sha256 cellar: :any,                 arm64_linux:       "d68c0305962650473d8dfab2a7296b1a360336772e74398ae92361719e52c449"
    sha256 cellar: :any,                 x86_64_linux:      "0ee68bba8e28b592133d898db2f581e973fbfbaf6d131a65cb8581da6a57d4ba"
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
