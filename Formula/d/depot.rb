class Depot < Formula
  desc "Build your Docker images in the cloud"
  homepage "https://depot.dev/"
  url "https://github.com/depot/cli/archive/refs/tags/v2.103.0.tar.gz"
  sha256 "35d5fc895a7cf6d63bc3dbb9e58d05d15695e05d9b0e5bd8c32d7dace0c9175f"
  license "MIT"
  head "https://github.com/depot/cli.git", branch: "main"

  # Upstream sometimes creates a tag with a stable version format but does not
  # create a release on GitHub.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "91fef7fc34af255ad63ba19b614b07ebb650593e49857a6e0e085c72695b89fc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "91fef7fc34af255ad63ba19b614b07ebb650593e49857a6e0e085c72695b89fc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "91fef7fc34af255ad63ba19b614b07ebb650593e49857a6e0e085c72695b89fc"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "58d66eccdb23b3cdb20dfe0cdec82093ad5c24f0ac72aff643a1688448f3eb0c"
    sha256 cellar: :any,                 x86_64_linux:      "62a4429d20443871ea1a4168282ccaeadc486a6160524183d1dd6c78c52ea4b6"
  end

  depends_on "go" => :build

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
