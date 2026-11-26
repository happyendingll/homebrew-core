class Tele < Formula
  desc "Telegram client for the terminal: a keyboard-first TUI and a CLI"
  homepage "https://github.com/sorokin-vladimir/tele"
  url "https://github.com/sorokin-vladimir/tele/archive/refs/tags/v2.1.4.tar.gz"
  sha256 "a06981a19a74d9ed63930e9f81ef70fd2e7bd301c2b5968eed8b1c684bb32d7a"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "6e972d62dcdb609414bbe74d6ad958a7644c42a5689c47ea15675fabacb7e36e"
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
    assert_match version.to_s, shell_output("#{bin}/tele --version")
    assert_match "dumped from tele-dark", shell_output("#{bin}/tele --theme-dump=tele-dark")
  end
end
