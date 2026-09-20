class Hookdeck < Formula
  desc "Forward webhook events from Hookdeck to a local server"
  homepage "https://hookdeck.com"
  url "https://github.com/hookdeck/hookdeck-cli/archive/refs/tags/v2.6.0.tar.gz"
  sha256 "141af8ff0bdb357310cb8662e5107a3b9928a4a44ce361a1928d65947d5e7383"
  license "Apache-2.0"
  head "https://github.com/hookdeck/hookdeck-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c09084f8f9ea88a717f60669dcb4d1620c60589f1f1f9d5a6bc2068bcc8768fb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/hookdeck/hookdeck-cli/pkg/version.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"hookdeck", "completion",
                                         shell_parameter_format: "--shell=",
                                         shells:                 [:bash, :zsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hookdeck --version")
    assert_match "Provide a project API key", shell_output("#{bin}/hookdeck ci 2>&1", 1)
  end
end
