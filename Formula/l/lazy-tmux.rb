class LazyTmux < Formula
  desc "Save all your tmux sessions and lazy restore them"
  homepage "https://lazy-tmux.xyz"
  url "https://github.com/alchemmist/lazy-tmux/archive/refs/tags/v0.3.7.tar.gz"
  sha256 "a7fdc0f4ea38d82bd611b2f24335447f959ebc60b0898aa41eeaea7e9d6782fb"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "1f904a92ae236f6efaf4b9ffe25c0aea751531c032970a53bd722f9938b5eecf"
  end

  depends_on "go" => :build

  depends_on "tmux"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/lazy-tmux"
  end

  test do
    config = testpath/"lazy-tmux.toml"
    ENV["LAZY_TMUX_CONFIG"] = config
    system bin/"lazy-tmux", "config", "gen"
    assert_match "# config source: #{config}\n", shell_output("#{bin}/lazy-tmux config show")
  end
end
