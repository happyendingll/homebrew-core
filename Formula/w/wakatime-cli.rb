class WakatimeCli < Formula
  desc "Command-line interface to the WakaTime api"
  homepage "https://wakatime.com/"
  url "https://github.com/wakatime/wakatime-cli.git",
      tag:      "v2.26.6",
      revision: "e9b64e8cc3bf32448b30f7b65fbf97d3465f5dbd"
  license "BSD-3-Clause"
  version_scheme 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "3e86de1a6bc73f2ff76301dee45d76801ef8b8152fa719d336a5ac1f1a998414"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    arch = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
    ldflags = %W[
      -X github.com/wakatime/wakatime-cli/pkg/version.Arch=#{arch}
      -X github.com/wakatime/wakatime-cli/pkg/version.BuildDate=#{time.iso8601}
      -X github.com/wakatime/wakatime-cli/pkg/version.Commit=#{Utils.git_head(length: 7)}
      -X github.com/wakatime/wakatime-cli/pkg/version.OS=#{OS.kernel_name.downcase}
      -X github.com/wakatime/wakatime-cli/pkg/version.Version=v#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)
    generate_completions_from_executable(bin/"wakatime-cli", shell_parameter_format: :cobra)
  end

  test do
    output = shell_output("#{bin}/wakatime-cli --help 2>&1")
    assert_match "Command line interface used by all WakaTime text editor plugins", output
  end
end
