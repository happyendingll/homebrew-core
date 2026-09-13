class Vacuum < Formula
  desc "World's fastest OpenAPI & Swagger linter"
  homepage "https://quobix.com/vacuum/"
  url "https://github.com/daveshanley/vacuum/archive/refs/tags/v0.30.4.tar.gz"
  sha256 "4421325406f980043afcb576217c69778caaab23b51b7fd81ea5bd4f6a360886"
  license "MIT"
  head "https://github.com/daveshanley/vacuum.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "85aee4a8a14da0b8fc63b0b25d83fcd4fc91489da5ecad04171b9571bbd71091"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "6b1a6f164a3908536ad7106e9c644ea880ea9fcf1607ce166e3b29141a6b7da0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "789e37e1fd3d24f982916e32c6112c627881d856f6cf18886aaf5bf597949c88"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "27e9a73d6605da533c11f562928ef6e212efc9392b522a495a696a9e8fd0ffaa"
    sha256 cellar: :any,                 x86_64_linux:      "c63369e5f963d2dd9755fdc57d9c285812ad96b493f3032be7ebcd2921271072"
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
