class Depot < Formula
  desc "Build your Docker images in the cloud"
  homepage "https://depot.dev/"
  url "https://github.com/depot/cli/archive/refs/tags/v2.102.11.tar.gz"
  sha256 "4d906c15a7cb7c92c54dd64eed73687587fb47d18346402d60c51a6e75c33149"
  license "MIT"
  head "https://github.com/depot/cli.git", branch: "main"

  # Upstream sometimes creates a tag with a stable version format but does not
  # create a release on GitHub.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "01d32e675fb426ef54ec4cb4a55f38c1f5fcfc6f61339271cd4c6ae140928551"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "01d32e675fb426ef54ec4cb4a55f38c1f5fcfc6f61339271cd4c6ae140928551"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "01d32e675fb426ef54ec4cb4a55f38c1f5fcfc6f61339271cd4c6ae140928551"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "99f060a51650d46c6544035ea13fc9137cf125eb86f82e4663b9f435944f9e8c"
    sha256 cellar: :any,                 x86_64_linux:      "4234c74a3ef10d85ff6ce7a53252f63ef92978f0e83e73594d15785886cab8e9"
  end

  depends_on "go" => :build

  # Fix linking on Linux arm64 with Go 1.27, which rejects cpuid 2.0.4's linkname to `runtime.sched_getaffinity`.
  patch do
    url "https://github.com/depot/cli/commit/627f8a6dfad7e7f2f33c774d3aa22af9884f0ebb.patch?full_index=1"
    sha256 "bffa3eaea34bebeeb3c27fb9ed326137b8824a1ded170eeeb2cdd91c30dd48ac"
    type :unofficial
    resolves "https://github.com/depot/cli/pull/570"
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/depot/cli/internal/build.Version=#{version}
      -X github.com/depot/cli/internal/build.Date=#{time.iso8601}
      -X github.com/depot/cli/internal/build.SentryEnvironment=release
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/depot"

    generate_completions_from_executable(bin/"depot", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/depot --version")
    output = shell_output("#{bin}/depot list builds 2>&1", 1)
    assert_match "unknown project ID", output
  end
end
