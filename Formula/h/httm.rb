class Httm < Formula
  desc "Interactive, file-level Time Machine-like tool for ZFS/btrfs"
  homepage "https://github.com/kimono-koans/httm"
  url "https://github.com/kimono-koans/httm/archive/refs/tags/0.51.1.tar.gz"
  sha256 "4c7e8947d41478f6f995046987614a1903e35766fe8a1a8e0847de7a7b805b24"
  license "MPL-2.0"
  head "https://github.com/kimono-koans/httm.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "a973839eccd82c0324f0a27cac5dbf9735f25af0e3a443fe55ff916a320a6274"
  end

  depends_on "rust" => :build

  on_linux do
    depends_on "acl"
  end

  conflicts_with "nicotine-plus", because: "both install `nicotine` binaries"

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(features: ["xattrs", "acls"])
    man1.install "httm.1"

    bin.install "scripts/ounce.bash" => "ounce"
    bin.install "scripts/bowie.bash" => "bowie"
    bin.install "scripts/nicotine.bash" => "nicotine"
    bin.install "scripts/equine.bash" => "equine"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/httm --version")

    touch testpath/"foo"
    output = shell_output("#{bin}/httm #{testpath}/foo 2>&1", 1)
    assert_match "WARN: httm could not identify any proximate dataset", output
    assert_match "ERROR: Requested paths do not currently exist", output
  end
end
