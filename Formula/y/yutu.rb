class Yutu < Formula
  desc "MCP server and CLI for YouTube"
  homepage "https://yutu.ifor.dev"
  url "https://github.com/eat-pray-ai/yutu/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "456affd706e72cdcc96c23bc3394b9011b9c1c2564054a155c081b70d05fcfb5"
  license "Apache-2.0"
  head "https://github.com/eat-pray-ai/yutu.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "5fa37f027e8fc545791a3eeec9d023fe87ad3e6645fccdff64eb6881e538dca6"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    mod = "github.com/eat-pray-ai/yutu/cmd"
    ldflags = %W[
      -X #{mod}.Os=#{OS.mac? ? "darwin" : "linux"}
      -X #{mod}.Arch=#{Hardware::CPU.arch}
      -X #{mod}.Version=v#{version}
      -X #{mod}.CommitDate=#{time.iso8601}
      -X #{mod}.Builder=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"yutu", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/yutu version 2>&1")

    assert_match "failed to parse client secret", shell_output("#{bin}/yutu auth 2>&1", 1)
  end
end
