class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.529.tar.gz"
  sha256 "89b6e8ab31da0e39b0bbdaa5954bff819734ae727158ec2474b60a06d3ad515a"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "3348aba549802f97ea8056c7c11b5058155cf9398520eb88baf848206247a876"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3348aba549802f97ea8056c7c11b5058155cf9398520eb88baf848206247a876"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3348aba549802f97ea8056c7c11b5058155cf9398520eb88baf848206247a876"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bdf4b1dc1bf0cf9727dfe87f6ba80ca3d9b0ddc7c43dbcca1470b881b104d114"
    sha256 cellar: :any,                 x86_64_linux:      "b10e33686487beb763efd1e2b1e01d37f914f3bc20747d18044bd3e1cfef74a4"
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
