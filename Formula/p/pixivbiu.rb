class Pixivbiu < Formula
  desc "Pixiv client. Easy to search, browse, and download artworks"
  homepage "https://github.com/txperl/PixivBiu"
  url "https://github.com/txperl/PixivBiu/archive/refs/tags/v3.1.6.tar.gz"
  sha256 "7d563a710921ac38bebd09d8c9e722b26ddeff42b449026bd6bacce835bd164b"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "6adaab7fd71959aafb102ee338ba4f29f155c3bc9ad0f61e7e2610fb72236f85"
  end

  depends_on "bun" => :build
  depends_on "go" => :build

  def install
    system "make", "dist", "VERSION=#{version}"
    bin.install "bin/pixivbiu"
  end

  test do
    port = free_port
    data_dir = testpath/"data"
    data_dir.mkdir
    ENV["PIXIVBIU_DATA_DIR"] = data_dir
    ENV["PIXIVBIU_SERVER_PORT"] = port.to_s

    pid = spawn bin/"pixivbiu", "open=false"
    assert_match '"status":"ok"', shell_output("curl -fsS --retry 10 --retry-connrefused --retry-delay 1 'http://127.0.0.1:#{port}/api/v1/health'")
  ensure
    Process.kill "SIGINT", pid
    Process.wait pid
  end
end
