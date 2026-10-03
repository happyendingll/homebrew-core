class Tfswitch < Formula
  desc "Command-line tool to switch between Terraform versions"
  homepage "https://tfswitch.warrensbox.com"
  url "https://github.com/warrensbox/terraform-switcher/archive/refs/tags/v1.20.0.tar.gz"
  sha256 "9cc776761add1d3a07f55db5ae0e53834341ec7b1ae8ec2dfa4e748907350761"
  license "MIT"
  head "https://github.com/warrensbox/terraform-switcher.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "81fdb839325c2a563a81ebf03b1156ccf2e4fdd7862c66a9f10a25a3d36992b1"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"

    system "go", "build", *std_go_args(ldflags: "-X main.version=v#{version}")

    bash_completion.install "completions/tfswitch.bash"
    fish_completion.install "completions/tfswitch.fish"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tfswitch --version")

    (testpath/"versions.tf").write <<~HCL
      terraform {
        required_version = "~> 1.5.0"
      }
    HCL
    assert_match 'Version "1.5.7" matches requirement "~> 1.5.0"',
                 shell_output("#{bin}/tfswitch --match-version-requirement 1.5.7 2>&1")
    assert_match 'Version "1.6.0" mismatches requirement "~> 1.5.0"',
                 shell_output("#{bin}/tfswitch --match-version-requirement 1.6.0 2>&1", 2)
  end
end
