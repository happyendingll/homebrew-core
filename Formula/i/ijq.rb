class Ijq < Formula
  desc "Interactive jq"
  homepage "https://codeberg.org/gpanders/ijq"
  url "https://codeberg.org/gpanders/ijq/archive/v1.4.1.tar.gz"
  sha256 "5a4397999a6dd7f3c31e6f907de7137ee9a1fa24e7a425718ce50f035b262036"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/gpanders/ijq.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "2daad25951d7a836cfc7c4dd2b2f047e56f2fc25d9276b32d55647819b778380"
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
