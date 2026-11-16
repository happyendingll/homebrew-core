class Yutu < Formula
  desc "CLI, MCP server, and AI agent to automate YouTube workflows"
  homepage "https://yutu.ifor.dev"
  url "https://github.com/eat-pray-ai/yutu/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "ed7606328bd4012d50417f4611076d9a908f07f4d3e5e7f81d032301d21aeda6"
  license "Apache-2.0"
  head "https://github.com/eat-pray-ai/yutu.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "c1b567fae43439df76d094ef6b6364770930143aa3552631b8b190c78224ed8c"
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
