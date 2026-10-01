class Syft < Formula
  desc "CLI for generating a Software Bill of Materials from container images"
  homepage "https://github.com/anchore/syft"
  url "https://github.com/anchore/syft/archive/refs/tags/v1.53.0.tar.gz"
  sha256 "33ef2c06455ce47835a8d9e57472aec575ba2058f889983c174e8e11a849467e"
  license "Apache-2.0"
  head "https://github.com/anchore/syft.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5ad942e00d6ab4812e6cf20888640f233f35f3c67edded75fd4ab84d1264d99d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "cf3b044424b173188552bc2256f205ec55adbf605dd3bb07f75bd208a50f5550"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "659d368e922fba41c24da9bc98ed55d8e416d15f70280b71847d2d48dc2c2d0a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "5fa250d0f33cd54017adcd78d7b4c745fcea606f28800919ce66449060e89dc2"
    sha256 cellar: :any,                 x86_64_linux:      "aceeeb45e2601cb09969a8a6bb9377830aeffc84b783df3eb52de7b449b64fcd"
  end

  depends_on "go" => :build

  # `test do` block downloads a test fixture resource
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.version=#{version}
      -X main.gitCommit=#{tap.user}
      -X main.buildDate=#{time.iso8601}
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/syft"

    generate_completions_from_executable(bin/"syft", shell_parameter_format: :cobra)
  end

  test do
    resource "homebrew-micronaut.cdx.json" do
      url "https://raw.githubusercontent.com/anchore/syft/934644232ab115b2518acdb5d240ae31aaf55989/syft/pkg/cataloger/java/test-fixtures/graalvm-sbom/micronaut.json"
      sha256 "c09171c53d83db5de5f2b9bdfada33d242ebf7ff9808ad2bd1343754406ad44e"
    end

    testpath.install resource("homebrew-micronaut.cdx.json")
    # Redirect stderr so the progress UI does not engage on the sandbox PTY and hang
    output = shell_output("#{bin}/syft convert #{testpath}/micronaut.json 2>/dev/null")
    assert_match "netty-codec-http2  4.1.73.Final  UnknownPackage", output

    assert_match version.to_s, shell_output("#{bin}/syft --version")
  end
end
