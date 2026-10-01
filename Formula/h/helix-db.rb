class HelixDb < Formula
  desc "Open-source graph-vector database built from scratch in Rust"
  homepage "https://helix-db.com"
  url "https://github.com/HelixDB/helix-db/archive/refs/tags/v3.4.1.tar.gz"
  sha256 "946a53daea9d34fd55f4f86e12c09465208f9797e6be1d78121e9a92a7f9bdcd"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "39087927aeaf3c36db6ee64898cdf7ebc46b6ae7ce1d303c34bde8993a021ce6"
  end

  depends_on "rust"

  on_linux do
    depends_on "openssl@3"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/cli")
  end

  test do
    project = testpath.to_s.split("/").last
    assert_match "Initialized #{project}", shell_output("#{bin}/helix init 2>&1")

    assert_path_exists testpath/"helix.toml"

    assert_match "Added test", shell_output("#{bin}/helix add local --name test 2>&1")
    assert_match "already exists in helix.toml", shell_output("#{bin}/helix add local --name test 2>&1", 1)

    assert_match "helix.toml already exists in #{testpath}", shell_output("#{bin}/helix init 2>&1", 1)
  end
end
