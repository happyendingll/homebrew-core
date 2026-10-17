class Librefang < Formula
  desc "Self-hostable operating system for autonomous AI agents"
  homepage "https://librefang.ai"
  url "https://github.com/librefang/librefang/archive/refs/tags/v2026.10.16.tar.gz"
  sha256 "513c4310967d66f7e3346384323ab3a26ec191cf9e3c75ad7cac44003fae3f74"
  license "MIT"
  head "https://github.com/librefang/librefang.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "8644e7b6754fc2c2b72c0938308dcd70a6d4507ed8fd4b2d9212f378c8d58ad3"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  on_linux do
    depends_on "dbus"
  end

  # Support Rust 1.99+
  patch do
    url "https://github.com/librefang/librefang/commit/2d0e85b0d6755aa928f552116ac9680c4eb16d26.patch?full_index=1"
    sha256 "2c6aaad8951e2f8adfc4293f147c15ebb4bf7dd1a0acaa97ccbda1c5303ec0df"
    type :unofficial
    resolves "https://github.com/librefang/librefang/pull/8635"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # Fat LTO exceeds the memory available on hosted Linux ARM64 builders.
    github_arm64_linux = OS.linux? && Hardware::CPU.arm? &&
                         ENV["HOMEBREW_GITHUB_ACTIONS"].present? &&
                         ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"].blank?
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "thin" if github_arm64_linux
    ENV.deparallelize if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]
    system "cargo", "install", *std_cargo_args(path: "crates/librefang-cli")
  end

  test do
    system bin/"librefang", "init", "--quick"
    assert_path_exists testpath/".librefang/config.toml"
  end
end
