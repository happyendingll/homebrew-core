class Herdr < Formula
  desc "Agent multiplexer that lives in your terminal"
  homepage "https://herdr.dev"
  url "https://github.com/herdrdev/herdr/archive/refs/tags/v0.9.2.tar.gz"
  sha256 "ff1a8ded511d29f84c3cc97816b4ea3510f10953166a185e669e9e7339100a8d"
  license "Apache-2.0"
  head "https://github.com/herdrdev/herdr.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "883a6ab660f1fa3d8cf8314b17fb11bdc2308cf9af92ba4b9d1470c56f7497ce"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "9b0064fcd76a03184baa3bbdc27a54e0301dfda926168dd60b773c7164af9a20"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "db0ffb447d1365362b5030ed408d294f1482bb4ad0d14bdafc17228f2409d200"
    sha256 cellar: :any,                 arm64_linux:       "807d36ae03bc29f6c7c496016be1e94c5552b3dae51d1b839722e292f72df747"
    sha256 cellar: :any,                 x86_64_linux:      "3a1a28e2e6bcf2b763744c0dfa2432de85d1f3a030ba1b527104ff2d7f3a21f2"
  end

  depends_on "rust" => :build
  depends_on "zig" => :build

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"herdr", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/herdr --version")

    ENV["HOME"] = testpath.to_s
    ENV["XDG_CONFIG_HOME"] = (testpath/"config").to_s
    ENV["XDG_STATE_HOME"] = (testpath/"state").to_s
    ENV["HERDR_CONFIG_PATH"] = (testpath/"config.toml").to_s
    ENV["HERDR_SOCKET_PATH"] = (testpath/"herdr.sock").to_s

    pid = spawn bin/"herdr", "server"
    status = ""
    10.times do
      status = shell_output("#{bin}/herdr status server")
      break if status.include?("status: running")

      sleep 1
    end
    assert_match "status: running", status
    assert_match "version: #{version}", status

    output = shell_output("#{bin}/herdr workspace create --label brew-test --no-focus")
    workspace = JSON.parse(output).dig("result", "workspace")
    assert_equal "brew-test", workspace["label"]

    output = shell_output("#{bin}/herdr workspace list")
    workspaces = JSON.parse(output).dig("result", "workspaces")
    assert_includes workspaces.map { |entry| entry["workspace_id"] }, workspace["workspace_id"]
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
