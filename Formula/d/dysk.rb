class Dysk < Formula
  desc "Linux utility to get information on filesystems, like df but better"
  homepage "https://dystroy.org/dysk/"
  url "https://github.com/Canop/dysk/archive/refs/tags/v3.8.0.tar.gz"
  sha256 "3c17e4ceb8d81855aec7ffb4b4346dd43cfe53cb94443e8a3419f3335919688f"
  license "MIT"
  head "https://github.com/Canop/dysk.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b5b075818cf2d08bb0f46eeac5319605e463ef9a587d3b191b7d97ea2b41aac4"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # TODO: Upstream forgot to bump the version, remove in the next release
    # https://github.com/Canop/dysk/issues/124
    inreplace %w[Cargo.lock Cargo.toml cli/Cargo.toml], "3.7.1", version.to_s

    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "filesystem", shell_output("#{bin}/dysk -s free-d")
    assert_match version.to_s, shell_output("#{bin}/dysk --version")
  end
end
