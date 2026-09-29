class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.487.tar.gz"
  sha256 "f9076a11f7953982d06ecf2f1264c765bdbc7cc4db3a76a153c71ba08efab98c"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8e809c03afef8b9d4e21672aab94e2ffc93751eb7f946d852e0c2fc05ac27961"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8e809c03afef8b9d4e21672aab94e2ffc93751eb7f946d852e0c2fc05ac27961"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "8e809c03afef8b9d4e21672aab94e2ffc93751eb7f946d852e0c2fc05ac27961"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c8f7387467169e85930cd5817f638545022821829bc264156d1638a40cd1af92"
    sha256 cellar: :any,                 x86_64_linux:      "42a9fabd763ebf33379771e77f627a2d92fab2c2acbb5b8b2aee674e1bbaf919"
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
