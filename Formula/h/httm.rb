class Httm < Formula
  desc "Interactive, file-level Time Machine-like tool for ZFS/btrfs"
  homepage "https://github.com/kimono-koans/httm"
  url "https://github.com/kimono-koans/httm/archive/refs/tags/0.51.0.tar.gz"
  sha256 "4c83d3a54aa2b4089e8009049dcf61f501ede0d5b6d03691b8d783bd43bb960b"
  license "MPL-2.0"
  head "https://github.com/kimono-koans/httm.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "a9e1c10c79879e79120dd2e5009a81b3769d6013d13926d41cde0df83c79239c"
  end

  depends_on "rust" => :build

  on_linux do
    depends_on "acl"
  end

  conflicts_with "nicotine-plus", because: "both install `nicotine` binaries"

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
