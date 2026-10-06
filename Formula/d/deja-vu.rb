class DejaVu < Formula
  desc "Local searchable memory over the session histories of coding agents"
  homepage "https://github.com/vshulcz/deja-vu"
  url "https://github.com/vshulcz/deja-vu/archive/refs/tags/v0.21.6.tar.gz"
  sha256 "bf87ce4c86d72db1bbbcf85f63cb6ed10f9d15ae8fd151a2959c2a818ec9cc84"
  license "MIT"
  head "https://github.com/vshulcz/deja-vu.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "39962afd41eca8f7ef8a6b6bb86106f39bbc75a960ee70e19b95e13d2a2718ee"
  end

  depends_on "go" => :build

  conflicts_with "deja", because: "both install `deja` binaries"

  deny_network_access! [:postinstall, :test]

  def install
    ldflags = "-X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags:, output: bin/"deja"), "./cmd/deja"

    generate_completions_from_executable(bin/"deja", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/deja version")
    assert_match '"schema_version": 2', shell_output("#{bin}/deja doctor --json --offline")
    assert_match "no matches", shell_output("#{bin}/deja search nothing-is-indexed-here 2>&1")
  end
end
