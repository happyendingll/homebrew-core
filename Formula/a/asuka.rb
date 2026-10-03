class Asuka < Formula
  desc "Gemini Project client written in Rust with NCurses"
  homepage "https://sr.ht/~julienxx/Asuka/"
  url "https://git.sr.ht/~julienxx/asuka/archive/0.8.5.tar.gz"
  sha256 "f7be2925cfc7ee6dcdfa4c30b9d4f6963f729c1b3f526ac242c7e1794bb190b1"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "501ba0b71b2d4049a4d41042b470bf1d85596a86b55f1500a34d4ef21e68e663"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "ncurses"

  on_linux do
    depends_on "openssl@3"
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    Open3.popen2("script -q screenlog.txt") do |input, _, wait_thr|
      input.puts "stty rows 80 cols 43"
      input.puts "env LC_CTYPE=en_US.UTF-8 LANG=en_US.UTF-8 TERM=xterm #{bin}/asuka"
      sleep 1
      input.putc "g"
      sleep 1
      input.puts "gemini://gemini.circumlunar.space"
      sleep 10
      input.putc "q"
      input.puts "exit"

      screenlog = File.open(testpath/"screenlog.txt", "r:ASCII-8BIT", &:read)
      assert_match "# Project Gemini", screenlog
    ensure
      Process.kill("TERM", wait_thr.pid)
    end
  end
end
