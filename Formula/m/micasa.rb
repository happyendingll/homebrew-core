class Micasa < Formula
  desc "TUI for tracking home projects, maintenance schedules, appliances and quotes"
  homepage "https://micasa.dev"
  url "https://github.com/micasa-dev/micasa/archive/refs/tags/v2.8.2.tar.gz"
  sha256 "147295292b73c6e94d1b4e139e54bf9b7f8dbee18932528c4f3959e6389a6cf4"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "e3b26128e2831a68246ea7a0f00433a059477e20f6b3dff1c18a4badc509f42c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/micasa"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/micasa --version")

    system bin/"micasa", "demo", "--seed-only", testpath/"demo.db"
    assert_path_exists testpath/"demo.db"
  end
end
