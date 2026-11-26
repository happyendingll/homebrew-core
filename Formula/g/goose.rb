class Goose < Formula
  desc "Go Language's command-line interface for database migrations"
  homepage "https://pressly.github.io/goose/"
  url "https://github.com/pressly/goose/archive/refs/tags/v3.30.2.tar.gz"
  sha256 "9a79b2a4c93cb9ee2de4dd30cf9fbe9d8d9ac57c851c3105b4a0bebcdd7ea875"
  license "MIT"
  head "https://github.com/pressly/goose.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "5ac5d0c3a177b7cec5374895c7122339737a98019f1ed2c124deda057d5da0df"
  end

  depends_on "go" => :build

  conflicts_with "block-goose-cli", "goose-lang", because: "both install `goose` binaries"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X main.version=v#{version}]
    system "go", "build", *std_go_args(ldflags:), "./cmd/goose"
  end

  test do
    output = shell_output("#{bin}/goose sqlite3 foo.db status create 2>&1", 1)
    assert_match "goose run: failed to collect migrations", output

    assert_match version.to_s, shell_output("#{bin}/goose --version")
  end
end
