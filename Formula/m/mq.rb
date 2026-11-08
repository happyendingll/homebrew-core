class Mq < Formula
  desc "Jq-like command-line tool for markdown processing"
  homepage "https://mqlang.org/"
  url "https://github.com/harehare/mq/archive/refs/tags/v0.10.1.tar.gz"
  sha256 "dec41709b9cf8db0995ff8157501264f0545597da80a7dae214970669c7e1f18"
  license "MIT"
  head "https://github.com/harehare/mq.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "225af69ad6a0d89e0d0b0ec90534ee31ca42377d43a45ebe17ce97571a9bb067"
  end

  depends_on "rust" => :build

  # Sync stale workspace versions in `Cargo.lock`
  patch do
    url "https://github.com/harehare/mq/commit/598e258355adc47ff0550d9a29bc23ef47b44633.patch?full_index=1"
    sha256 "62cce5ecdd76438abcca477a16eda4222d2befc77d434f101cd131571b143f84"
    type :backport
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/mq-run")
    system "cargo", "install", *std_cargo_args(path: "crates/mq-lsp")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mq --version")

    (testpath/"test.md").write("# Hello World\n\nThis is a test.")
    output = shell_output("#{bin}/mq '.h' #{testpath}/test.md")
    assert_equal "# Hello World\n", output
  end
end
