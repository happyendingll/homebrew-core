class Navidrome < Formula
  desc "Modern Music Server and Streamer compatible with Subsonic/Airsonic"
  homepage "https://www.navidrome.org"
  url "https://github.com/navidrome/navidrome/archive/refs/tags/v0.64.0.tar.gz"
  sha256 "0f395ee2672d32eed9da9ad6b16ec21d1a270d3ba5299fd638ddca237db5fa4c"
  license "GPL-3.0-only"
  head "https://github.com/navidrome/navidrome.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "ca84db4704e7fec0c8e39b1d37b8cf076e2c192d8f813180ec48a4d53152a80e"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "pkgconf" => :build
  depends_on "ffmpeg"
  depends_on "taglib"

  def install
    # Workaround to avoid patchelf corruption when cgo is required
    if OS.linux? && Hardware::CPU.arch == :arm64
      ENV["CGO_ENABLED"] = "1"
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    ldflags = %W[
      -X github.com/navidrome/navidrome/consts.gitTag=v#{version}
      -X github.com/navidrome/navidrome/consts.gitSha=source_archive
    ]

    system "make", "setup"
    system "make", "buildjs"
    system "go", "build", *std_go_args(ldflags:, tags: "netgo,sqlite_fts5"), "-buildvcs=false"

    generate_completions_from_executable(bin/"navidrome", shell_parameter_format: :cobra)
  end

  test do
    assert_equal "#{version} (source_archive)", shell_output("#{bin}/navidrome --version").chomp
    port = free_port
    pid = spawn bin/"navidrome", "--port", port.to_s
    sleep 20
    assert_equal ".", shell_output("curl http://localhost:#{port}/ping")
  ensure
    Process.kill "KILL", pid
    Process.wait pid
  end
end
