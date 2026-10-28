class Vacuum < Formula
  desc "World's fastest OpenAPI & Swagger linter"
  homepage "https://quobix.com/vacuum/"
  url "https://github.com/daveshanley/vacuum/archive/refs/tags/v0.35.6.tar.gz"
  sha256 "2c028a7421f1c5d62a198487ad3f873ea27485f5d03ebe7d37cd8a457d5b467e"
  license "MIT"
  head "https://github.com/daveshanley/vacuum.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8e55e5e9b823fd9a0211d3abc04ad26ba3bc3f4542c6e4aacb474c5e5b4a9e1f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "9b8b14867f700cb8d359609201d75a7d17e603c386bf012a2754cbb8c8eeeaa8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "fc79e14455459d3cf1d1d9ed8aa89b10085de310395a1f67ea7b014e9fb4f619"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "919fb3320e2ab0e8024e6f65535ed8cbf6c552ed8a90cdc5d82be663143068dc"
    sha256 cellar: :any,                 x86_64_linux:      "06db5edcb31aab601b681724257b704e99b72abba3837683a26f5e1a5a2f1c2e"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  def install
    cd "html-report/ui" do
      system "npm", "install", *std_npm_args(prefix: false)
      system "npm", "run", "build"
    end

    ldflags = "-X main.version=#{version} -X main.commit=#{tap.user} -X main.date=#{time.iso8601}"
    system "go", "build", *std_go_args(ldflags:, tags: "html_report_ui")

    generate_completions_from_executable(bin/"vacuum", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vacuum version")

    (testpath/"test-openapi.yml").write <<~YAML
      openapi: 3.0.0
      info:
        title: Test API
        version: 1.0.0
      paths:
        /test:
          get:
            responses:
              '200':
                description: Successful response
    YAML

    output = shell_output("#{bin}/vacuum lint #{testpath}/test-openapi.yml 2>&1", 1)
    assert_match "Failed with 2 errors, 3 warnings and 0 informs.", output

    output = shell_output("#{bin}/vacuum html-report 2>&1", 2)
    assert_match "please supply an OpenAPI", output
    assert_match "generate an HTML Report", output
    refute_match "html-report support is not included in this build", output
  end
end
