class Hookdeck < Formula
  desc "Forward webhook events from Hookdeck to a local server"
  homepage "https://hookdeck.com"
  url "https://github.com/hookdeck/hookdeck-cli/archive/refs/tags/v3.0.1.tar.gz"
  sha256 "96f60a3ac4174794db455e205e652394f2787cd9939dde3a05beaf3a5be4ab12"
  license "Apache-2.0"
  head "https://github.com/hookdeck/hookdeck-cli.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "bc77436d993cc68341d492d51e92f72ff3ecc99e7920d68c88b1b776ba335555"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bc77436d993cc68341d492d51e92f72ff3ecc99e7920d68c88b1b776ba335555"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "bc77436d993cc68341d492d51e92f72ff3ecc99e7920d68c88b1b776ba335555"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8439d2ac944dd6f3c438ca0ab29dad8850125b56cc8bde9d4a1d8bcba98e0f4c"
    sha256 cellar: :any,                 x86_64_linux:      "eb49befcc32046fecfb720f479ba2caeba12e5a2d58a83557e2d69eed1152258"
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
