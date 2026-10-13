class PhotocraftCli < Formula
  desc "Headless PhotoCraft engine to convert, inspect and batch-edit images"
  homepage "https://getartcraft.com/apps/photocraft"
  url "https://github.com/storytold/photocraft/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "420bc64e3548579b1b255aed33be055be1688c3427f429dc5f1c28daf8639a2c"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/storytold/photocraft.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "19b6c45df28b698ce6866e84b00198d2db95910d30b7531bd33e81d562409eff"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "6c850489cb3566d712f19b8cd047be51acd9eb1ea26f4b75f634a46a666a0c82"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "82df443967373bd73de61aaaf396bb4268409c37cb9732334542c175cffffb0d"
    sha256 cellar: :any,                 arm64_linux:       "b722b942dfd2ab524a283546fb4692f32ff2dd20e656f7239e1f7f49bc8d2897"
    sha256 cellar: :any,                 x86_64_linux:      "e62ed36a52fcb3181cd518e485c7c62cd1db8ffb0cf9a8d053c8543b03094354"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "apps/photocraft-cli", features: "heif")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/photocraft-cli --version")

    system bin/"photocraft-cli", "run", "--new", '{"width":16,"height":12}',
           "--cmd", "layer.new.layer", "--out", "test.pcraft"
    info = JSON.parse(shell_output("#{bin}/photocraft-cli info test.pcraft --compact"))
    assert_equal [16, 12], [info["width"], info["height"]]
    assert_equal ["Layer 1", "Background"], info["layers"].map { |layer| layer["name"] }

    system bin/"photocraft-cli", "convert", "test.pcraft", "test.png"
    assert_equal "\x89PNG".b, (testpath/"test.png").binread(4)
  end
end
