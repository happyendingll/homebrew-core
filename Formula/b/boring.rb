class Boring < Formula
  desc "Simple command-line SSH tunnel manager that just works"
  homepage "https://alebeck.github.io/boring/"
  url "https://github.com/alebeck/boring/archive/refs/tags/v0.18.2.tar.gz"
  sha256 "6e8682e046de4d8ce2b034c28923810eab932fd0a6bce24bed9ee259a1603fca"
  license "MIT"
  head "https://github.com/alebeck/boring.git", branch: "main"

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "7aec025814e573a2ed569f5bdbbb112471e02cf5c924f386e6d4bfc60f38b877"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/alebeck/boring/internal/buildinfo.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/boring"

    generate_completions_from_executable(bin/"boring", "--shell")
  end

  post_install_steps do
    terminate_process "boring", must_succeed: false
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/boring version")

    (testpath/(OS.linux? ? ".config/boring" : "")/".boring.toml").write <<~TOML
      [[tunnels]]
      name = "dev"
      local = "9000"
      remote = "localhost:9000"
      host = "dev-server"
    TOML

    # Keep the daemon socket inside testpath, the only place the test sandbox allows unix sockets
    ENV["BORING_SOCK"] = testpath/"boringd.sock"
    assert_match "dev   9000   ->  localhost:9000  dev-server", shell_output("#{bin}/boring list")
  end
end
