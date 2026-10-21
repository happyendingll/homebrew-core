class Syft < Formula
  desc "CLI for generating a Software Bill of Materials from container images"
  homepage "https://github.com/anchore/syft"
  url "https://github.com/anchore/syft/archive/refs/tags/v1.55.0.tar.gz"
  sha256 "d402b3988cdaea74bc01763830a6e45b4a3f1ada40f8fcad7edb5b230c18f1eb"
  license "Apache-2.0"
  head "https://github.com/anchore/syft.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "439c29121fdd91e93609e3d8c9517fd80bc5db9ce0b8d4a0b48e99bbff474a39"
  end

  depends_on "go" => :build

  resource "homebrew-micronaut.cdx.json", :test do
    url "https://raw.githubusercontent.com/anchore/syft/934644232ab115b2518acdb5d240ae31aaf55989/syft/pkg/cataloger/java/test-fixtures/graalvm-sbom/micronaut.json"
    sha256 "c09171c53d83db5de5f2b9bdfada33d242ebf7ff9808ad2bd1343754406ad44e"
  end

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
    testpath.install resource("homebrew-micronaut.cdx.json")
    # Redirect stderr so the progress UI does not engage on the sandbox PTY and hang
    output = shell_output("#{bin}/syft convert #{testpath}/micronaut.json 2>/dev/null")
    assert_match "netty-codec-http2  4.1.73.Final  UnknownPackage", output

    assert_match version.to_s, shell_output("#{bin}/syft --version")
  end
end
