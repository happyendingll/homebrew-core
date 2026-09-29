class Tuios < Formula
  desc "Terminal UI OS (Terminal Multiplexer)"
  homepage "https://tuios.gaurav.zip/"
  url "https://github.com/Gaurav-Gosain/tuios/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "8c5d7e09a463b144dfb96fe561c8e936889d3befa2f1da1f3e6b9480628fe390"
  license "MIT"
  head "https://github.com/Gaurav-Gosain/tuios.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "05a3ef51c576cc07253c2e77d3429c6e45eac934344a86cf9f8b3744cde8dd8c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/tuios"

    generate_completions_from_executable(bin/"tuios", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tuios --version")

    assert_match "git_hub_dark", shell_output("#{bin}/tuios --list-themes")
  end
end
