class Treemd < Formula
  desc "TUI and CLI dual pane markdown viewer"
  homepage "https://github.com/epistates/treemd"
  url "https://github.com/Epistates/treemd/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "9808666913e3698eef1372e614044678a32ba7cdc6da514080c442c12ee3fed9"
  license "MIT"
  head "https://github.com/epistates/treemd.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "3d9d0bbeebcc80be4bc557d1982785ba9f01129ec42fb68875689d1f581d9385"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"treemd", shell_parameter_format: :clap)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/treemd --version")

    (testpath/"test.md").write("# Test Heading\n\nThis is a test paragraph.")

    assert_equal (testpath/"test.md").read, shell_output("#{bin}/treemd test.md")
    assert_equal "# Test Heading\n", shell_output("#{bin}/treemd --list test.md")
  end
end
