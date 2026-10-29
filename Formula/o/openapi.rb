class Openapi < Formula
  desc "CLI tools for working with OpenAPI, Arazzo and Overlay specifications"
  homepage "https://www.speakeasy.com"
  url "https://github.com/speakeasy-api/openapi/archive/refs/tags/v1.26.1.tar.gz"
  sha256 "abc0e17fc0898e90677992f09098a73f25e7ca9dbfd3019749f8a3d7b724fa2e"
  license "MIT"
  head "https://github.com/speakeasy-api/openapi.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c9ed5f6c905f037533c0384235abbf84c979ed693b51ac36c946463795b610fd"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c9ed5f6c905f037533c0384235abbf84c979ed693b51ac36c946463795b610fd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c9ed5f6c905f037533c0384235abbf84c979ed693b51ac36c946463795b610fd"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "9b38570e4517b0352c9369f21dbc73b3b4fef76896f8e1dbe52b923614643c59"
    sha256 cellar: :any,                 x86_64_linux:      "1391df113487ab6ecbf3c5ec21de68dd37c2d38c8ad16a8bb678f847a90ac9fc"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/openapi"

    generate_completions_from_executable(bin/"openapi", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/openapi --version")

    system bin/"openapi", "spec", "bootstrap", "test-api.yaml"
    assert_path_exists testpath/"test-api.yaml"

    system bin/"openapi", "spec", "validate", "test-api.yaml"
  end
end
