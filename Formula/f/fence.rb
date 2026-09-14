class Fence < Formula
  desc "Lightweight sandbox for commands with network and filesystem restrictions"
  homepage "https://github.com/fencesandbox/fence"
  url "https://github.com/fencesandbox/fence/archive/refs/tags/v0.1.67.tar.gz"
  sha256 "f2e55bd108816d224f45b3115e0c8feba2cb1a92055f0ebf7839f82b87a84f35"
  license "Apache-2.0"
  head "https://github.com/fencesandbox/fence.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "37c1a9a595978b0bc590a2bdacbae43d0d05db2e289e65f7a62997f52cac37e3"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "bubblewrap" => :no_linkage
    depends_on "socat" => :no_linkage
  end

  def install
    ldflags = %W[
      -X main.version=#{version}
      -X main.buildTime=#{time.iso8601}
      -X main.gitCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/fence"

    generate_completions_from_executable(bin/"fence", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fence --version")

    # General functionality cannot be tested in CI due to sandboxing,
    # but we can test that config import works.
    (testpath/".claude/settings.json").write <<~JSON
      {}
    JSON
    system bin/"fence", "import", "--claude", "-o", testpath/".fence.json"
    assert_path_exists testpath/".fence.json"
  end
end
