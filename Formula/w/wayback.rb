class Wayback < Formula
  desc "Archiving tool integrated with various archival services"
  homepage "https://docs.wabarc.eu.org"
  url "https://github.com/wabarc/wayback/archive/refs/tags/v0.21.1.tar.gz"
  sha256 "b52cf015420852b99246cde0d0183ec746a1c851ff2e9ebbed80e05be7eccfa7"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "7988d2fa643af212c7dab05eb10e12ee68128dd8aec9aa535201c7bfc197a31f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/wabarc/wayback/version.Version=#{version}
      -X github.com/wabarc/wayback/version.Commit=#{tap.user}
      -X github.com/wabarc/wayback/version.BuildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/wayback"
    generate_completions_from_executable(bin/"wayback", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wayback --version")

    (testpath/"wayback.conf").write "WAYBACK_POOLING_SIZE=9\n"
    output = shell_output("#{bin}/wayback --print --config #{testpath}/wayback.conf 2>&1")
    assert_match "poolingSize: (int) 9", output
  end
end
