class Appwrite < Formula
  desc "Command-line tool for Appwrite"
  homepage "https://appwrite.io"
  url "https://github.com/appwrite/sdk-for-cli/archive/refs/tags/28.15.0.tar.gz"
  sha256 "10a9ee2c244c7a2ec1d426b612afe182567b453aa4a76c1561f9242340459e88"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "bd72b4df0f1bf8c4cf5b5587bd16c90dc2a0689f89722200e2dd5812cadd39a4"
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
