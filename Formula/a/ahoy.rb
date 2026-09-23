class Ahoy < Formula
  desc "Creates self documenting CLI programs from commands in YAML files"
  homepage "https://ahoy-cli.github.io/"
  url "https://github.com/ahoy-cli/ahoy/archive/refs/tags/v3.0.1.tar.gz"
  sha256 "ed4d3b48784668dc48b81243125dbdeabecaab784b5e1c20f1608cacf83dc4ce"
  license "MIT"
  head "https://github.com/ahoy-cli/ahoy.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "39df056d443a5851cb6d9617643d692b73a56c6279baabe57e6ffe51e660fa69"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}-homebrew")
  end

  test do
    (testpath/".ahoy.yml").write <<~YAML
      ahoyapi: v2
      commands:
        hello:
          cmd: echo "Hello Homebrew!"
    YAML
    assert_equal "Hello Homebrew!\n", shell_output("#{bin}/ahoy hello")

    assert_equal "#{version}-homebrew", shell_output("#{bin}/ahoy --version").strip
  end
end
