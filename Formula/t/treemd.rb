class Treemd < Formula
  desc "TUI and CLI dual pane markdown viewer"
  homepage "https://github.com/epistates/treemd"
  url "https://github.com/Epistates/treemd/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "74cf698a520ae60eddba6135e5322bb06deae6474b356d69e3b367fb79a86c35"
  license "MIT"
  head "https://github.com/epistates/treemd.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "45540c0c0ba82205d07d901f1720926aefd0ed0430f9091432d1a7903b9f784b"
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
