class Hstr < Formula
  desc "Bash and zsh history suggest box"
  homepage "https://github.com/dvorka-oss/hstr"
  url "https://github.com/dvorka/hstr/releases/download/v.3.3/hstr-3.3.0-tarball.tgz"
  sha256 "2e030cb0575d57d7d4010602b9bbaa1e7362c11ad349b109f823fad30c69dd10"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "18d8e89a8047b9a0103b6a068c11a18046873e354e57f60ad1b879145425516a"
  end

  depends_on "pkgconf" => :build
  depends_on "readline"

  uses_from_macos "ncurses"

  deny_network_access!

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    require "pty"
    require "io/console"

    ENV["HISTFILE"] = testpath/".hh_test"
    (testpath/".hh_test").write("test\n")

    output = ""
    PTY.spawn(bin/"hh", "-n") do |r, _w, _pid|
      r.winsize = [24, 80]
      begin
        r.each_line { |line| output += line }
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      end
    end
    assert_match "test", output
  end
end
