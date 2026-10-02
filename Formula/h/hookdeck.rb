class Hookdeck < Formula
  desc "Forward webhook events from Hookdeck to a local server"
  homepage "https://hookdeck.com"
  url "https://github.com/hookdeck/hookdeck-cli/archive/refs/tags/v3.1.0.tar.gz"
  sha256 "547e736f87e027070702db53ad0ba077788c5e8d7eefbcb18e8221a1c0b45c84"
  license "Apache-2.0"
  head "https://github.com/hookdeck/hookdeck-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "353fc9c14cf360371541848db832067595a3300127a337b98cc9a41de1efb5df"
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
