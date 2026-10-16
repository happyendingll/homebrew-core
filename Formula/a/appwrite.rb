class Appwrite < Formula
  desc "Command-line tool for Appwrite"
  homepage "https://appwrite.io"
  url "https://github.com/appwrite/sdk-for-cli/archive/refs/tags/28.6.0.tar.gz"
  sha256 "1ba20b7c200c7d6754476a98dd8c9eb8c3b7c6d552ce3cd4ed0ddeec4eb712b3"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "31e70481dffa4f828d7cedf462e46368c8a958b36b7aeaf0aa6b5dd97c6554dd"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "31e70481dffa4f828d7cedf462e46368c8a958b36b7aeaf0aa6b5dd97c6554dd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "31e70481dffa4f828d7cedf462e46368c8a958b36b7aeaf0aa6b5dd97c6554dd"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "1aa55e6e515950181eadc46a3055676c9d98efa072a309ff0a5eb61ed0c401d6"
    sha256 cellar: :any,                 x86_64_linux:      "ce35e07e388877e8c04cf4e9f3c0bd9220a7b5a528932f9bcc5973583bb24ba6"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    # `go mod tidy` needs module metadata beyond what `go mod download` fetches
    system "go", "mod", "tidy"
  end

  def install
    # https://github.com/appwrite/sdk-for-cli/blob/4399a3321898f40cf982acbd4859d506c9d4d9f4/.goreleaser.yaml#L19-L22
    system "go", "mod", "tidy"
    system "go", "build", *std_go_args(ldflags: "-X github.com/appwrite/sdk-for-cli/internal/app.Version=#{version}")

    generate_completions_from_executable(bin/"appwrite", "completion")
  end

  test do
    output = shell_output("#{bin}/appwrite client --endpoint http://localhost/v1 2>&1", 1)
    assert_match "Error: invalid endpoint", output

    assert_match version.to_s, shell_output("#{bin}/appwrite --version")
  end
end
