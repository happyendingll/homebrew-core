class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.509.tar.gz"
  sha256 "56c66cf9675ba11744cf112cf58728a944a309865fc4f5e8274d1e9214030a4f"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e3f732f7d956621055d3617bf57d0c4e28910606ab242e8b9034e3dd1152e09f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e3f732f7d956621055d3617bf57d0c4e28910606ab242e8b9034e3dd1152e09f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e3f732f7d956621055d3617bf57d0c4e28910606ab242e8b9034e3dd1152e09f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "54b4d6e5ebdbb6dad25e7484caf1c3b072275a7fcbc17be4a9ae60606b4bc9ae"
    sha256 cellar: :any,                 x86_64_linux:      "1a86d04f73923bd9bcc7c8718188e097d736670816bb40d29bc5657f3d2afd74"
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
