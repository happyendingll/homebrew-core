class Termsvg < Formula
  desc "Record, share and export your terminal as a animated SVG image"
  homepage "https://github.com/MrMarble/termsvg"
  url "https://github.com/MrMarble/termsvg/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "193c8004a8c91b49518ecb5712009369035092288bb2a1189d188f2410332bae"
  license "GPL-3.0-only"
  head "https://github.com/MrMarble/termsvg.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "ef80ffd02642b27394ef93c0fc8a496b7c021351a76779b86d492472cc51b178"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X main.version=#{version} -X main.commit=#{tap.user} -X main.date=#{time.iso8601}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/termsvg"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/termsvg --version")

    output = shell_output("#{bin}/termsvg play nonexist 2>&1", 80)
    assert_match "no such file or directory", output
  end
end
