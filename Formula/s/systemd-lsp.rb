class SystemdLsp < Formula
  desc "Language server for systemd unit files"
  homepage "https://github.com/JFryy/systemd-lsp"
  url "https://github.com/JFryy/systemd-lsp/archive/refs/tags/v2026.09.28.tar.gz"
  sha256 "d9fe3b5b81eb6d9363e2ed324909868810ffd2d7a49eb24233524d292db28de8"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "884e75f25e7dd035ea3abefa708e07fdf0c1b9cf4c1957127fa48e13382387dd"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    (testpath/"test.service").write <<~EOS
      [Service]
      ExecTest=brew
    EOS
    assert_match "Unknown directive 'ExecTest' in [Service] section",
      shell_output("#{bin}/systemd-lsp test.service")
  end
end
