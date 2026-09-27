class Vortix < Formula
  desc "Terminal UI for WireGuard and OpenVPN with live telemetry and leak guarding"
  homepage "https://github.com/Harry-kp/vortix"
  url "https://github.com/Harry-kp/vortix/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "65d7ba9be74d538833113c488fb9a94aad1f11413ccdf0fc3087dd8bfe835125"
  license "MIT"
  head "https://github.com/Harry-kp/vortix.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "8cba43034d9161f8a7df0cc7a8c7104c5345ee10b7950449f8614eb822b33e77"
  end

  depends_on "rust" => :build
  depends_on "openvpn"
  depends_on "wireguard-tools"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/vortix")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vortix --version")
    # Mode names are checked before the root check, so this runs unprivileged.
    assert_match "off, block-on-drop, vpn-only", shell_output("#{bin}/vortix killswitch auto 2>&1", 1)
  end
end
