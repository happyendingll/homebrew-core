class ConfigFileValidator < Formula
  desc "CLI tool to validate different configuration file types"
  homepage "https://boeing.github.io/config-file-validator/"
  url "https://github.com/Boeing/config-file-validator/archive/refs/tags/v3.0.0.tar.gz"
  sha256 "987931434d0fe2b5bdc4fc4c630a7c2f2f05ca51d1245f5c269c139a9e9e296c"
  license "Apache-2.0"
  head "https://github.com/Boeing/config-file-validator.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "76d55aa0ef9ddca0b21d54ca5ceb2ed6e23aaa40a9cb15ffd8fe973463d20c67"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/Boeing/config-file-validator/v3.version=#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"cfv"), "./cmd/cfv"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cfv -version")

    test_file = testpath/"test.json"
    test_file.write <<~JSON
      { "valid": "json" }
    JSON
    assert_match "✓ #{test_file}", shell_output("#{bin}/cfv #{test_file}")
  end
end
