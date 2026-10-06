class Hcloud < Formula
  desc "Command-line interface for Hetzner Cloud"
  homepage "https://github.com/hetznercloud/cli"
  url "https://github.com/hetznercloud/cli/archive/refs/tags/v1.70.0.tar.gz"
  sha256 "022a610f22da8bb0f1206a23cbc5f62e1f1553fb52747388ad5624dc9ec37333"
  license "MIT"
  head "https://github.com/hetznercloud/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "80031836a2412776f46ba40ff7947914ad9c44599c19ad1fc264b4f19c53b33b"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/hetznercloud/cli/internal/version.version=v#{version}
      -X github.com/hetznercloud/cli/internal/version.versionPrerelease=
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/hcloud"

    generate_completions_from_executable(bin/"hcloud", shell_parameter_format: :cobra)
  end

  test do
    config_path = testpath/".config/hcloud/cli.toml"
    ENV["HCLOUD_CONFIG"] = config_path
    assert_match "", shell_output("#{bin}/hcloud context active")
    config_path.write <<~EOS
      active_context = "test"
      [[contexts]]
      name = "test"
      token = "foobar"
    EOS
    assert_match "test", shell_output("#{bin}/hcloud context list")
    assert_match "test", shell_output("#{bin}/hcloud context active")
    assert_match "hcloud v#{version}", shell_output("#{bin}/hcloud version")
  end
end
