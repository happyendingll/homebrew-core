class Mcpsnoop < Formula
  desc "Transparent proxy and TUI for debugging MCP traffic"
  homepage "https://github.com/kerlenton/mcpsnoop"
  url "https://github.com/kerlenton/mcpsnoop/archive/refs/tags/v0.23.0.tar.gz"
  sha256 "a23ce56f8895a485cb056ea7d1e697be0ef9d1ef224db1d2789f0e9d5de8ff32"
  license "MIT"
  head "https://github.com/kerlenton/mcpsnoop.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "ada8d09357b53705d51db51bdd7bb016c31416f0ebe3be3da70c439353369df1"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/mcpsnoop"
    generate_completions_from_executable(bin/"mcpsnoop", "completion")
  end

  test do
    ENV["MCPSNOOP_HOME"] = testpath
    assert_match version.to_s, shell_output("#{bin}/mcpsnoop version")

    # Wrap a trivial "server" so the shim writes a real session, then check it.
    system bin/"mcpsnoop", "--label", "brewtest", "--", "true"
    assert_match "brewtest", shell_output("#{bin}/mcpsnoop export -T text")
  end
end
