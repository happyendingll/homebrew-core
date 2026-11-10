class Terramate < Formula
  desc "Managing Terraform stacks with change detections and code generations"
  homepage "https://terramate.io/docs/"
  url "https://github.com/terramate-io/terramate/archive/refs/tags/v0.17.4.tar.gz"
  sha256 "3f95c5d24efd57c6af8935ecf22461b17f1a8c9867bfc1269cd8849e19910cfc"
  license "MPL-2.0"
  head "https://github.com/terramate-io/terramate.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "94954eb5590e6a7ec42d5575cbdeac3376a5fb892c53251d852e6ff92d2642d2"
  end

  depends_on "go" => :build

  conflicts_with "tenv", because: "both install terramate binary"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(output: bin/"terramate"), "./cmd/terramate"
    system "go", "build", *std_go_args(output: bin/"terramate-ls"), "./cmd/terramate-ls"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/terramate version")
    assert_match version.to_s, shell_output("#{bin}/terramate-ls -version")
  end
end
