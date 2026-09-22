class Tfmcp < Formula
  desc "Terraform Model Context Protocol (MCP) Tool"
  homepage "https://github.com/nwiizo/tfmcp"
  url "https://github.com/nwiizo/tfmcp/archive/refs/tags/v0.2.3.tar.gz"
  sha256 "4be94ef2a0779e679506cf83b200638c1073cc9718fc6a9125712eb8d5000da5"
  license "MIT"
  head "https://github.com/nwiizo/tfmcp.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "74d6da60e7c36044a33d607d20f5fa6aec3e9574a95b6279582bb00a07219fdb"
  end

  depends_on "rust" => :build
  depends_on "opentofu" => :test

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tfmcp --version")

    ENV["TERRAFORM_BINARY_NAME"] = "tofu"

    output = shell_output("#{bin}/tfmcp analyze 2>&1")
    assert_match "Terraform analysis complete", output
    assert_match "Hello from tfmcp!", (testpath/"main.tf").read
  end
end
