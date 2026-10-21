class Ijq < Formula
  desc "Interactive jq"
  homepage "https://codeberg.org/gpanders/ijq"
  url "https://codeberg.org/gpanders/ijq/archive/v1.4.2.tar.gz"
  sha256 "1c19df50facbf5374fbd6fc04edb20437e2605c712b592a8fb5dfed033fead5c"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/gpanders/ijq.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "d1fae455783f2d8e7b9444c1f369fc16f04cacbeb26b0dadff7b3d9627e1c014"
  end

  depends_on "go" => :build
  depends_on "scdoc" => :build

  uses_from_macos "jq", since: :sequoia

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "make", "prefix=#{prefix}", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ijq -V")

    ENV["TERM"] = "xterm"

    (testpath/"filterfile.jq").write '["foo", "bar", "baz"] | sort | add'
    output_log = testpath/"output.log"

    require "expect"
    require "pty"
    PTY.spawn(bin/"ijq", "-H", "", "-M", "-n", "-f", "filterfile.jq",
              [:out, :err] => output_log.to_s) do |r, w, pid|
      refute_nil r.expect("barbazfoo", 5), "Expected barbazfoo"
      w.write "\r"
      r.read
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    ensure
      r.close
      w.close
      Process.wait(pid)
    end
    assert_match "\"barbazfoo\"", output_log.read
  end
end
