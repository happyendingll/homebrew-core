class Flyline < Formula
  desc "Supercharged Bash plugin replacement for readline"
  homepage "https://github.com/HalFrgrd/flyline"
  url "https://github.com/HalFrgrd/flyline/archive/refs/tags/v1.11.0.tar.gz"
  sha256 "c805d6227252d51e1863a9901a34f6b6b157b243cc0ca18651da11aa13f1da7b"
  license any_of: ["GPL-3.0-only", "MIT"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "0629d3050240fb31ff25f3d8e7cc69504d1fe77e1d271ec7faf8673266d88d08"
  end

  depends_on "rust" => :build
  depends_on "bash" => :test

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    cargo_args = std_cargo_args.reject { |arg| arg["--root"] || arg["--path"] }
    system "cargo", "build", "--lib", "--release", *cargo_args
    (lib/"bash").install shared_library("target/release/libflyline") => "flyline"
  end

  test do
    require "io/console"
    require "pty"

    output_log = testpath/"output.log"
    PTY.spawn(formula_opt_bin("bash")/"bash", "--noprofile", "--norc", "-i",
              [:out, :err] => output_log.to_s) do |r, w, pid|
      r.winsize = [80, 130]
      w.puts "enable flyline"
      w.puts "flyline version"
      w.puts "flyline changelog"
      w.puts "exit"
      r.read
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    ensure
      r.close
      w.close
      Process.wait(pid)
    end

    output = output_log.read
    assert_match "Changelog", output
    assert_match version.to_s, output
  end
end
