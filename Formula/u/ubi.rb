class Ubi < Formula
  desc "Universal Binary Installer"
  homepage "https://github.com/houseabsolute/ubi"
  url "https://github.com/houseabsolute/ubi/archive/refs/tags/v0.13.0.tar.gz"
  sha256 "bb4c14fd505c55443038fc3ef224b56e84a7730eb754ded6322d8b5521b97bda"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/houseabsolute/ubi.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "10352ceb5687b01101d2ab6c310ec090ed416810543c195d29add1e0696c4065"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  depends_on "xz" # required for lzma support

  uses_from_macos "bzip2"

  def install
    system "cargo", "install", *std_cargo_args(path: "ubi-cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ubi --version")

    system bin/"ubi", "--project", "houseabsolute/precious"
    system testpath/"bin/precious", "--version"
  end
end
