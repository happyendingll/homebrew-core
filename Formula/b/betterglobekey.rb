class Betterglobekey < Formula
  desc "Reworked Globe key for faster input source switching"
  homepage "https://github.com/Serpentiel/betterglobekey"
  url "https://github.com/Serpentiel/betterglobekey/archive/refs/tags/v4.3.0.tar.gz"
  sha256 "c47ec61e7c177136b39bbb2aabcb621af878da858bf1a2cbc1e2e558eceb946e"
  license "MIT"
  head "https://github.com/Serpentiel/betterglobekey.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "b8140794cab4683be561f4dd794b16d9b25a41211ca553245d80b8647fdf365e"
  end

  depends_on "go" => :build
  depends_on :macos

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}")
    generate_completions_from_executable(bin/"betterglobekey", "completion")
  end

  service do
    run opt_bin/"betterglobekey"
    keep_alive true
    log_path var/"log/betterglobekey.log"
    error_log_path var/"log/betterglobekey.log"
  end

  test do
    list = shell_output("#{bin}/betterglobekey list")
    assert_match(/^com\.apple\.keylayout\./, list)
  end
end
