class Deja < Formula
  desc "Predictive ghost-text autosuggestions for zsh"
  homepage "https://github.com/Giammarco-Ferranti/deja"
  url "https://github.com/Giammarco-Ferranti/deja/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "c122b5556558f87e754398ea1f1b8d0f5276d2249939db487b1b780f616ec1c8"
  license "MIT"
  head "https://github.com/Giammarco-Ferranti/deja.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e8e3d631ba157aa2fc1bfea6f7fecd95fb4b9f18eb9e007dd7ef072343d3b279"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" # Required by `go-sqlite3`

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/deja"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/deja version")

    history = testpath/"zsh_history"
    history.write <<~HISTORY
      : 1757000000:0;git status
      : 1757000001:0;git checkout main
      : 1757000002:0;docker compose up -d
    HISTORY
    assert_match "imported 3 commands",
      shell_output("#{bin}/deja import --file #{history}")

    # `query` falls back to a direct SQLite read when the daemon is not
    # running, so this exercises the importer, store, and fuzzy scorer.
    assert_equal "git checkout main",
      shell_output("#{bin}/deja query --buffer 'git ceckout'").chomp
  end
end
