class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.539.tar.gz"
  sha256 "3881f27bc02f5cfbe0466fe987c2c3e080ddb39af578a120b8f92e7247f09d75"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0508f327ec1ba7ab8fbdc57c2d024eb0cee7100a12da383af38df8c876af030e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "0508f327ec1ba7ab8fbdc57c2d024eb0cee7100a12da383af38df8c876af030e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0508f327ec1ba7ab8fbdc57c2d024eb0cee7100a12da383af38df8c876af030e"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8c707bb791af1867f4bbaf641457ab6710bc5273430f4ceddfbeaa9e9e011c5c"
    sha256 cellar: :any,                 x86_64_linux:      "7762aecb5e3a8ff59aa6585ab94b43356016491c9f0e4c44012e4e26769029a6"
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
