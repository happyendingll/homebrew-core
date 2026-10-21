class PocketId < Formula
  desc "Open-source identity provider for secure user authentication"
  homepage "https://pocket-id.org"
  url "https://github.com/pocket-id/pocket-id/archive/refs/tags/v2.19.0.tar.gz"
  sha256 "c78002e0871d2b6bd01938f8528a6be8f7bbd022f25bdf71dddb52b89fc04ba1"
  license "BSD-2-Clause"
  head "https://github.com/pocket-id/pocket-id.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1991243352642bc2b6eb8674c7af1b0890f0060e6e0733d5ad07b71679b99e38"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ff40f4cd3e7ced941b49a8c951541213bbf8215e993f0682f8f0082f25bac43f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "07916dcc6d9f0ac0cb97b512045f67c20ce3cbb059eaa5ff44cf0c6c077d6dad"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4ef3bced708055d2119078b083ef74adfd255d16306fb01d6e59ab4bcddbc905"
    sha256 cellar: :any,                 x86_64_linux:      "ad13cc698b65fc0d6310912186a34d8e99fa2fd04e0d1a524043de3d08aef4ac"
  end

  depends_on "go" => :build
  depends_on "node" => :build
  depends_on "pnpm" => :build

  allow_network_access! :test

  def fetch
    system "pnpm", "with", "current", "--dir", "frontend", "install", "--frozen-lockfile", "--ignore-scripts"
    system "go", "mod", "download", "-C", "backend/cmd"
  end

  def install
    system "pnpm", "with", "current", "--dir", "frontend", "run", "build"
    system "go", "build", "-C", "backend/cmd", *std_go_args(output: bin/"pocket-id")
  end

  service do
    run [opt_bin/"pocket-id"]
    keep_alive true
    working_dir var/"pocket-id"
    log_path var/"log/pocket-id.log"
    error_log_path var/"log/pocket-id.log"
  end

  test do
    port = free_port
    (testpath/"test.db").write ""
    (testpath/".env").write <<~ENV
      APP_URL=http://localhost:#{port}
      ENCRYPTION_KEY=test-key-for-ci-123456789012345678901234
      DB_CONNECTION_STRING=#{testpath}/test.db
      PORT=#{port}
    ENV

    pid = spawn bin/"pocket-id"
    sleep 5

    system "curl", "-s", "--fail", "http://127.0.0.1:#{port}/health"
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
