class Gotpm < Formula
  desc "CLI for using TPM 2.0"
  homepage "https://github.com/google/go-tpm-tools"
  url "https://github.com/google/go-tpm-tools/archive/refs/tags/v0.4.11.tar.gz"
  sha256 "050823ea0aa7bcc14a31f090ffb79bbb9ec5d96fadbb0094e63e75636b67fbe9"
  license "Apache-2.0"
  head "https://github.com/google/go-tpm-tools.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c5c5ce423b5a29d3c72cfd3608d3f3957c375faf44bcfe1140b8f4721228319a"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/gotpm"
    generate_completions_from_executable(bin/"gotpm", shell_parameter_format: :cobra)
  end

  test do
    output = shell_output("#{bin}/gotpm attest 2>&1", 1)
    assert_match "Error: connecting to TPM: stat /dev/tpm0: no such file or directory", output
  end
end
