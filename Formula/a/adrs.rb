class Adrs < Formula
  desc "Architectural Decision Record tool in Rust"
  homepage "https://joshrotenberg.com/adrs/"
  url "https://github.com/joshrotenberg/adrs/archive/refs/tags/v0.12.1.tar.gz"
  sha256 "f8c66465ba16f8f28f5123c59a365b5b08ebb02ef6918e1e9c003bd822989bd9"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/joshrotenberg/adrs.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "f8ba22d492c53faa09b3d5a3947bef0f0a3c42ed17c1e28d1d5a66272cb1af58"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/adrs")
    generate_completions_from_executable(bin/"adrs", "completions")
  end

  test do
    # Exercise `adrs doctor` as a CI lint gate: it exits 0 for advisory findings
    # and non-zero for structural errors. Drive a sample ADR through the
    # advisory path — ADR014 (advisory: placeholder text left in a fresh template)
    system bin/"adrs", "init", "docs/decisions"

    # init seeds a Nygard-format ADR; drop it so the demo below is MADR-only.
    (testpath/"docs/decisions/0001-record-architecture-decisions.md").unlink

    system bin/"adrs", "new", "--format", "madr", "--no-edit",
           "Use Homebrew for software installation"
    assert_match "ADR014", shell_output("#{bin}/adrs doctor")

    assert_match version.to_s, shell_output("#{bin}/adrs --version")
  end
end
