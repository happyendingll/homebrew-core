class Gotpm < Formula
  desc "CLI for using TPM 2.0"
  homepage "https://github.com/google/go-tpm-tools"
  url "https://github.com/google/go-tpm-tools/archive/refs/tags/v0.4.10.tar.gz"
  sha256 "a40ecfff3222c9303c4fd0fb7aae9aa60f74bb7a7c649df661daaf5db47c6f80"
  license "Apache-2.0"
  head "https://github.com/google/go-tpm-tools.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "843508fd639ba3d8320c8c3ad7e4037d6a13f7459ab82f68f71eec80989d9afb"
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
