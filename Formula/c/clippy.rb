class Clippy < Formula
  desc "Copy files from your terminal that actually paste into GUI apps"
  homepage "https://github.com/neilberkman/clippy"
  url "https://github.com/neilberkman/clippy/archive/refs/tags/v1.9.1.tar.gz"
  sha256 "27e6934defdfe662037f59e0c5b6671399abb1c14985697b876c0e17c0e2b779"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "c1c9651bddb937dfad5cbe79dd8fb5862a2a637b2bcf5bb8c8211db06117e59a"
  end

  depends_on "go" => :build
  depends_on :macos

  def install
    ldflags = %W[
      -X github.com/neilberkman/clippy/cmd/internal/common.Version=#{version}
      -X github.com/neilberkman/clippy/cmd/internal/common.Commit=#{tap.user}
      -X github.com/neilberkman/clippy/cmd/internal/common.Date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/clippy"
    system "go", "build", *std_go_args(ldflags:, output: bin/"pasty"), "./cmd/pasty"

    %w[clippy pasty].each do |cmd|
      generate_completions_from_executable(bin/cmd, shell_parameter_format: :cobra)
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clippy --version")
    assert_match version.to_s, shell_output("#{bin}/pasty --version")

    # Writing to the pasteboard needs a GUI session, so exercise the MCP server's file buffer instead
    (testpath/"test.txt").write("test content\n")
    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}
      {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"buffer_copy","arguments":{"file":"#{testpath}/test.txt"}}}
    JSON
    assert_match "Copied 2 lines from test.txt", pipe_output("#{bin}/clippy mcp-server 2>&1", json, 0)
  end
end
