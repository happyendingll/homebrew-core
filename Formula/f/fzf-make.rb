class FzfMake < Formula
  desc "Fuzzy finder with preview window for various command runners including make"
  homepage "https://github.com/kyu08/fzf-make"
  url "https://github.com/kyu08/fzf-make/archive/refs/tags/v0.74.0.tar.gz"
  sha256 "3297dcff19019ff4099bfd271cd8463109bdd590a2ba5213d65ca3cd1b5d9d33"
  license "MIT"
  head "https://github.com/kyu08/fzf-make.git", branch: "main"

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "0e4acc63c6a7ea9d895a180fb214d3dd152a5f8915523eff76ce6b04ad9ee2d4"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fzf-make -v")

    (testpath/"Makefile").write <<~MAKE
      brew:
        cc test.c -o test
    MAKE

    begin
      output_log = testpath/"output.log"
      if OS.mac?
        pid = spawn bin/"fzf-make", [:out, :err] => output_log.to_s
      else
        require "pty"
        r, _w, pid = PTY.spawn("#{bin}/fzf-make > #{output_log} 2>&1")
        r.winsize = [80, 130]
      end
      sleep 5
      assert_match "make brew", output_log.read
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
