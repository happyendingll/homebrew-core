class IcannRdap < Formula
  desc "Full-rich client for the Registry Data Access Protocol (RDAP) sponsored by ICANN"
  homepage "https://github.com/icann/icann-rdap/wiki"
  url "https://github.com/icann/icann-rdap/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6103c53142b20f55b6868793c29e13bda15852eda24cb50444b812ed4a3a967b"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "eb63870e16b554679820e3647dfb1382e1f6c7ec8ce03ffaf101ab19436cb7c6"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  conflicts_with "rdap", because: "rdap also ships a rdap binary"

  def install
    system "cargo", "install", "--bin=rdap", *std_cargo_args(path: "icann-rdap-cli")
    system "cargo", "install", "--bin=rdap-test", *std_cargo_args(path: "icann-rdap-cli")
  end

  test do
    mkdir ".config"
    assert_match "icann-rdap-cli #{version}", shell_output("#{bin}/rdap -V")
    assert_match "icann-rdap-cli #{version}", shell_output("#{bin}/rdap-test -V")

    # lookup com TLD at IANA with rdap
    url = "https://rdap.iana.org/domain/com"
    output = shell_output("#{bin}/rdap -O pretty-json #{url}")
    assert_match '"ldhName": "com"', output

    # test com TLD at IANA with rdap-test
    output = shell_output("#{bin}/rdap-test -O pretty-json --skip-v6 -C gtld-profile-error #{url}")
    assert_match '"status_code": 200', output
  end
end
