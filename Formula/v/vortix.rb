class Vortix < Formula
  desc "Terminal UI for WireGuard and OpenVPN with live telemetry and leak guarding"
  homepage "https://github.com/Harry-kp/vortix"
  url "https://github.com/Harry-kp/vortix/archive/refs/tags/v0.5.5.tar.gz"
  sha256 "2ad10a08225b9eb7069234f41aa3f719d7cc8fbaae6202cc3f34250ab74f1da2"
  license "MIT"
  head "https://github.com/Harry-kp/vortix.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "30800e94a875585576c11ff7b37ac76765f963c97cbfdcf2fff7cbe41d0b975f"
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
