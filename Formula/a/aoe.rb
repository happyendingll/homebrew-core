class Aoe < Formula
  desc "Terminal session manager for AI coding agents"
  homepage "https://github.com/agent-of-empires/agent-of-empires"
  url "https://github.com/agent-of-empires/agent-of-empires/archive/refs/tags/v1.26.0.tar.gz"
  sha256 "561416b072a06c6ab907bbe04fb23d2f47fc1af1972bc30ac044ef945d6785b9"
  license "MIT"
  head "https://github.com/agent-of-empires/agent-of-empires.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "a69c38003da4df1db8c5b8eab1fc5957f7064d77370b786fdd0c79ba484835e2"
  end

  depends_on "node" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@4"
  depends_on "tmux" => :no_linkage

  uses_from_macos "sqlite", since: :tahoe # requires sqlite3_set_clientdata

  on_linux do
    depends_on "aws-lc" # cannot use on macOS due to openssl symbol conflict
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
    cd "web" do
      system "npm", "ci", *std_npm_args(prefix: false)
    end
  end

  allow_network_access! :test

  def fetch
    cd "web" do
      system "npm", "install", *std_npm_args(prefix: false)
    end
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["AWS_LC_SYS_USE_SYSTEM"] = "1" if OS.linux?
    ENV["LIBGIT2_NO_VENDOR"] = "1"
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"

    system "cargo", "install", *std_cargo_args(features: "web")
    generate_completions_from_executable(bin/"aoe", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    # Keep the tmux socket out of the shared `/tmp`, where the sandbox blocks connecting to stale ones
    ENV["TMUX_TMPDIR"] = testpath

    assert_match version.to_s, shell_output("#{bin}/aoe --version")

    system bin/"aoe", "init", testpath
    assert_match "Agent of Empires", (testpath/".agent-of-empires/config.toml").read

    output = shell_output("#{bin}/aoe init #{testpath} 2>&1", 1)
    assert_match "already exists", output

    status = JSON.parse(shell_output("#{bin}/aoe status --json"))
    assert_equal 0, status["total"]

    port = free_port
    with_test_process(bin/"aoe", "serve", "--port", port.to_s, "--no-auth", "--behind-proxy", "--allowed-host",
"127.0.0.1") do
      output = shell_output("curl --silent --retry 5 --retry-connrefused http://127.0.0.1:#{port}")
      assert_match "Agent of Empires", output
    end
  end
end
