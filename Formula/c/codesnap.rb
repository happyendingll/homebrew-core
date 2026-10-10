class Codesnap < Formula
  desc "Generates code snapshots in various formats"
  homepage "https://codesnap-docs.netlify.app/"
  url "https://github.com/codesnap-rs/codesnap/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "21599899581c0a8dcdd3a8fcb30e212a521aa99bac35b9ad04ace2ae8059e256"
  license "MIT"
  head "https://github.com/codesnap-rs/codesnap.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any_skip_relocation, sequoia: "14a9c5f68255091717af1c820aa50a15ef562d88a8527fc0b413d982d3c7ba63"
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
