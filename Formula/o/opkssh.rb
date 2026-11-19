class Opkssh < Formula
  desc "Enables SSH to be used with OpenID Connect"
  homepage "https://eprint.iacr.org/2023/296"
  url "https://github.com/openpubkey/opkssh/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "3cd05f22e2ed2293b28c3223d1482502ce14b9e5e12ef5d54b68855566cfb33e"
  license "Apache-2.0"
  head "https://github.com/openpubkey/opkssh.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "ee5c8ba9cfda240f3add5b0d8698e84bddb8064a8ded76a4671c865db2d11bad"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.Version=#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/opkssh --version")

    output = shell_output("#{bin}/opkssh add brew brew brew 2>&1", 1)
    assert_match "Failed to add to policy", output
  end
end
