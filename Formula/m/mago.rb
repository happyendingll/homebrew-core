class Mago < Formula
  desc "Toolchain for PHP to help developers write better code"
  homepage "https://github.com/carthage-software/mago"
  url "https://github.com/carthage-software/mago/releases/download/1.56.1/source-code.tar.gz"
  sha256 "47b4133f10a7024a3c10d936a010ff3cc543338b13ff92aaec01e17d164930f4"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "bce5d242920a7bfcb13b0e2bea92f2a91b1a3dba0d0648612ba8db917f8294f6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "68d8f014f14339b23082dc5bd50c11a9a3c97578583c1688cfccc4dec35ac442"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "21ec12a60b4b089a46b14d7b3005cd634d264972ed7e8edd7d77317a1d208231"
    sha256 cellar: :any,                 arm64_linux:       "0c1013d4889ff07679d71e453beef147bd8c27f0de9107d776049102636d0885"
    sha256 cellar: :any,                 x86_64_linux:      "306638905c4ba00547e7ecf4b4b6bae47e87478b6a90852de11876111a1f5353"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mago --version")

    (testpath/"example.php").write("<?php echo 'Hello, Mago!';")
    output = shell_output("#{bin}/mago lint . 2>&1")
    assert_match "Missing `declare(strict_types=1);` statement at the beginning of the file", output

    (testpath/"unformatted.php").write("<?php echo 'Unformatted';?>")
    system bin/"mago", "fmt"
    assert_match "<?php echo 'Unformatted';?>", (testpath/"unformatted.php").read
  end
end
