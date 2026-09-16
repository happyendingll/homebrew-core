class Yazi < Formula
  desc "Blazing fast terminal file manager written in Rust, based on async I/O"
  homepage "https://yazi-rs.github.io"
  url "https://github.com/sxyazi/yazi/archive/refs/tags/v26.9.1.tar.gz"
  sha256 "66857f1b670469daf258edd0bb2ea51d9ad3e2cab4eea9684028c80059fd6862"
  license "MIT"
  head "https://github.com/sxyazi/yazi.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "45bf4a41bbbdedcd396411dcff0dc5d3e92d6c6c8eb7d869f2a798dc953e4bf2"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    ENV["VERGEN_GIT_SHA"] = tap.user
    ENV["YAZI_GEN_COMPLETIONS"] = "1"
    system "cargo", "install", *std_cargo_args(path: "yazi-fm")
    system "cargo", "install", *std_cargo_args(path: "yazi-cli")

    bash_completion.install "yazi-boot/completions/yazi.bash" => "yazi"
    zsh_completion.install "yazi-boot/completions/_yazi"
    fish_completion.install "yazi-boot/completions/yazi.fish"

    bash_completion.install "yazi-cli/completions/ya.bash" => "ya"
    zsh_completion.install "yazi-cli/completions/_ya"
    fish_completion.install "yazi-cli/completions/ya.fish"
  end

  test do
    # yazi is a GUI application
    assert_match version.to_s, shell_output("#{bin}/yazi --version").strip
  end
end
