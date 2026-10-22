class Exercism < Formula
  desc "Command-line tool to interact with exercism.io"
  homepage "https://exercism.io/cli/"
  url "https://github.com/exercism/cli/archive/refs/tags/v3.5.9.tar.gz"
  sha256 "8595fc3e8b0ff3fcff7cc56a67bee58156665e71eee1ff9eace593568ec8debf"
  license "MIT"
  head "https://github.com/exercism/cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "b64a7cffc19e17f82f527b1282fb0281e705edd225c7ffc8084509fef6ac0e3b"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "exercism/main.go"

    bash_completion.install "shell/exercism_completion.bash" => "exercism"
    zsh_completion.install "shell/exercism_completion.zsh" => "_exercism"
    fish_completion.install "shell/exercism.fish"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/exercism version")
  end
end
