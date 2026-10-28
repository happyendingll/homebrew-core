class Betterglobekey < Formula
  desc "Reworked Globe key for faster input source switching"
  homepage "https://github.com/Serpentiel/betterglobekey"
  url "https://github.com/Serpentiel/betterglobekey/archive/refs/tags/v4.3.0.tar.gz"
  sha256 "c47ec61e7c177136b39bbb2aabcb621af878da858bf1a2cbc1e2e558eceb946e"
  license "MIT"
  head "https://github.com/Serpentiel/betterglobekey.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "79abcb931d488ef272acaac57803a49f7f2023d40fd7ea5d4dc4bbbf03c57eef"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3e1f0c07b6d499527afa51d1f95f77c219525234ff3ed6026acd5a5e4cae3a7d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6ba0b5f5b15a5dc45bd29fc1ee6f5d17d63ad917d00bccb7bcea2fad23f2fcb2"
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
