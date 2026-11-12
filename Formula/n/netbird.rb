class Netbird < Formula
  desc "Securely connects across any network with one identity-based platform"
  homepage "https://netbird.io"
  url "https://github.com/netbirdio/netbird/archive/refs/tags/v0.82.1.tar.gz"
  sha256 "faea65ed0321a285818ad4458da5b0441c6f6f766c9fd963cb7dfc5cd9bf4445"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "89d527a9e1572fdf87701e32b2e552d0bff607dd4397f74d1749430512f64000"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -X github.com/netbirdio/netbird/version.version=#{version}
      -X main.commit=NONE
      -X main.date=#{time.iso8601}
      -X main.builtBy=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./client"
    generate_completions_from_executable(bin/"netbird", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/netbird version")
    status_output = shell_output("#{bin}/netbird status --daemon-addr unix://#{testpath}/netbird.sock 2>&1", 1)
    assert_match "failed to connect to {Addr: \"#{testpath}/netbird.sock\"", status_output
  end
end
