class Gmailctl < Formula
  desc "Declarative configuration for Gmail filters"
  homepage "https://github.com/mbrt/gmailctl"
  url "https://github.com/mbrt/gmailctl/archive/refs/tags/v0.13.0.tar.gz"
  sha256 "49df3a2fe7929114ec406096d577004a27ad75bbb4c836ca603dff88c1a830bd"
  license "MIT"
  head "https://github.com/mbrt/gmailctl.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "2af12172e78175718bc0dec87091b089e861dc84f362e2ad39fc7cf9ecd7ac0e"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/mbrt/gmailctl/cmd/gmailctl/cmd.version=#{version}]
    system "go", "build", *std_go_args(ldflags:), "cmd/gmailctl/main.go"

    generate_completions_from_executable(bin/"gmailctl", shell_parameter_format: :cobra)
  end

  test do
    assert_includes shell_output("#{bin}/gmailctl init --config #{testpath} 2>&1", 1),
      "The credentials are not initialized"

    assert_match version.to_s, shell_output("#{bin}/gmailctl version")
  end
end
