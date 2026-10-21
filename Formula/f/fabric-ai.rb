class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.534.tar.gz"
  sha256 "dc8bd5b88dcd8e22ae17d5b59ead7b81f6f710c19f95fb86915dec0f1278cbef"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "382c3565acbf0f01ac21beef12cef862bf89f917c76ae6bed5dbd828b78aa114"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "382c3565acbf0f01ac21beef12cef862bf89f917c76ae6bed5dbd828b78aa114"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "382c3565acbf0f01ac21beef12cef862bf89f917c76ae6bed5dbd828b78aa114"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "f96a0b00a29a2489af7a2a5f253534df8a37bce8cd33d731e7422013318dd095"
    sha256 cellar: :any,                 x86_64_linux:      "c8c791d0bd19300c5446c163731cd9ee9c356985ff42bd63a4662927ede895fb"
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
