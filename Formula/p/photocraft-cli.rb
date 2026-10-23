class PhotocraftCli < Formula
  desc "Headless PhotoCraft engine to convert, inspect and batch-edit images"
  homepage "https://getartcraft.com/apps/photocraft"
  url "https://github.com/storytold/photocraft/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "78577ed3436769f5783dd1f5a5f0c118018dd905bf6ca33ee4d72c8440ff5be3"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/storytold/photocraft.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e91c3c8f50e1c02d09b0a6d039e6a90dd7988f8f0e01bc45dfb746e89baaa6fc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "6f89dadc5928f90c2a274c3b444076279a98c00cd9bdfb4d55ed638dbbebe5ea"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "18ab04a983b97e23e010e1acd44d29bc8bb13f684e6a9bd5ce29e644ebda4702"
    sha256 cellar: :any,                 arm64_linux:       "90ab48473a03df69a4b73953a4cd03447f2ee73ac0fcc47a1dd7d3a31718d907"
    sha256 cellar: :any,                 x86_64_linux:      "0e151b05af4944879dba5beb25b789bb15136d695a0d0188298ee8c9bf4406bb"
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
