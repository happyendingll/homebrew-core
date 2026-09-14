class Treemd < Formula
  desc "TUI and CLI dual pane markdown viewer"
  homepage "https://github.com/epistates/treemd"
  url "https://github.com/Epistates/treemd/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "0b427bfba89da24e89a44fcf2cc14b95845f2fdf48ab4c29e6f808763a6af9e4"
  license "MIT"
  head "https://github.com/epistates/treemd.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "78ddad14ea49f36b0283ee6e045444ce9f75183192fdff4cd57ec4bc48eb097a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "02f001d827e9332aa7729c8d8b6d7587fef47407981b77f384e40992723f1448"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "8bbfb07057cdf46af7cd214cb40dd7cb9884c81b30ea53f3a18f6e906fc10625"
    sha256 cellar: :any,                 arm64_linux:       "84ba2577d6e2448af0260ea8d5b94dbd6e22a2db7d2fb67c83099aa474ba4059"
    sha256 cellar: :any,                 x86_64_linux:      "4ba0811c2acbf975efc0cf92287cfd7dd96ec0ff5027f123ac391ba9ef0119fe"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/treemd --version")

    (testpath/"test.md").write("# Test Heading\n\nThis is a test paragraph.")

    begin
      output_log = testpath/"output.log"
      if OS.mac?
        pid = spawn bin/"treemd", testpath/"test.md", [:out, :err] => output_log.to_s
      else
        require "pty"
        r, _w, pid = PTY.spawn("#{bin}/treemd #{testpath}/test.md > #{output_log}")
        r.winsize = [80, 43]
      end
      sleep 3
      assert_match "treemd - test.md - 1 headings", output_log.read
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
