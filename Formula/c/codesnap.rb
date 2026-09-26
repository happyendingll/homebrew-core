class Codesnap < Formula
  desc "Generates code snapshots in various formats"
  homepage "https://codesnap-docs.netlify.app/"
  url "https://github.com/codesnap-rs/codesnap/archive/refs/tags/v0.13.4.tar.gz"
  sha256 "47a249efd507c0e1dcd8122da1d263b2bf00dcedfa27eed976a02909cefe0725"
  license "MIT"
  head "https://github.com/codesnap-rs/codesnap.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c1afbcc449eee799aa97b05523d469bcb6a30443dbf173cd54cbafe8f85254ee"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "cli")

    pkgshare.install "cli/examples"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/codesnap --version")
    assert_match "SUCCESS", shell_output("#{bin}/codesnap -f #{pkgshare}/examples/cli.sh -o cli.png")
  end
end
