class Appwrite < Formula
  desc "Command-line tool for Appwrite"
  homepage "https://appwrite.io"
  url "https://github.com/appwrite/sdk-for-cli/archive/refs/tags/28.12.1.tar.gz"
  sha256 "35de2aab6890962ddede4e3e38eb8cd8372ca707f8e6285e68e8bcf8d31d061d"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "0fb39f969d25049c46894ad08cf70a7ba5060036cbb85d54f5c92db2f9e41152"
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
