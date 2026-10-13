class Tele < Formula
  desc "Keyboard-first Telegram client for the terminal, written in Go"
  homepage "https://github.com/sorokin-vladimir/tele"
  url "https://github.com/sorokin-vladimir/tele/archive/refs/tags/v1.11.11.tar.gz"
  sha256 "4752ea05f58a77d43d955fc2b96b61d0aa2d3e380d470a48d66a6b2579e39e0c"
  license "GPL-3.0-only"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ba4def7b1db58d4d5f4cdc0e0ced2e947106222bf82b1b041c94328e62ae5792"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a215521f8a77e1c864433bdb18e2213d8742aace35a5414b0b58def546d69f06"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4c0b3b57c292cd4721d0da9ce5a43835d2d122ecb229ba3c57d5802afe40ec81"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "e522e19cd8068bc419362f8a1d9992a2decb83ebd6c715f9a42b8f8c23ff4e9a"
    sha256 cellar: :any,                 x86_64_linux:      "b933e4a5ef73e3a9ae18bf5ded5f9b7a4a4fd1da029fa419487c45cc4fac9edb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X github.com/sorokin-vladimir/tele/internal/version.Version=#{version}"), "./cmd/tele"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tele -version")
    assert_match "dumped from tele-dark", shell_output("#{bin}/tele -theme-dump tele-dark")
  end
end
