class Mq < Formula
  desc "Jq-like command-line tool for markdown processing"
  homepage "https://mqlang.org/"
  license "MIT"
  head "https://github.com/harehare/mq.git", branch: "main"

  stable do
    url "https://github.com/harehare/mq/archive/refs/tags/v0.9.1.tar.gz"
    sha256 "b95445ceb09821d34014d5fc7d90d25f1169d8ad2bec89c9e519bf416a71fa54"

    # v0.9.1 tag missed the workspace version bump in `Cargo.lock`
    patch do
      url "https://github.com/harehare/mq/commit/84bb58896def94aa74f8027009e453680d5ff695.patch?full_index=1"
      sha256 "6ec6a7301edc89fbea4dd519dee1d689c60f52af8be9fd7ed359843086403485"
      type :backport
      resolves "https://github.com/harehare/mq/pull/2431"
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "30e6c2bb8d8d146c4d2658e5515028164a16831882e4805b9e6a34bafea7209b"
  end

  depends_on "rust" => :build

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
