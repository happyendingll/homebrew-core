class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.494.tar.gz"
  sha256 "21a64d54138407c8c9c734e44953b08af29b7bf8ddc359183ce9690a5c4af698"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "36a446e158122ef78a4c73311a83006a7a6ddf7a71234087e800683e4610fdde"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "36a446e158122ef78a4c73311a83006a7a6ddf7a71234087e800683e4610fdde"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "36a446e158122ef78a4c73311a83006a7a6ddf7a71234087e800683e4610fdde"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bd3b0dad27897f92cb2cb245bacba939059609cffb4be8373ce6fa521f52667c"
    sha256 cellar: :any,                 x86_64_linux:      "f5193265635b9c66172b4fed207cd2a0bf45a736e16b31f929e63d1d13bca08b"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/fabric"
    # Install completions
    bash_completion.install "completions/fabric.bash" => "fabric-ai"
    fish_completion.install "completions/fabric.fish" => "fabric-ai.fish"
    zsh_completion.install "completions/_fabric" => "_fabric-ai"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fabric-ai --version")

    (testpath/".config/fabric/.env").write("t\n")
    output = pipe_output("#{bin}/fabric-ai --dry-run 2>&1", "", 1)
    assert_match "error loading .env file: unexpected character", output
  end
end
