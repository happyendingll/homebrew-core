class AllSmi < Formula
  desc "GPU monitoring tool for NVIDIA/Jetson/Apple Silicon/Tenstorrent"
  homepage "https://github.com/lablup/all-smi"
  url "https://github.com/lablup/all-smi/archive/refs/tags/v0.27.0.tar.gz"
  sha256 "31703c3b4a0bcb53eec9bd9c613a4327e310459bb5f22d0b276a69de989b3a8f"
  license "Apache-2.0"
  head "https://github.com/lablup/all-smi.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "65474554271d4523b7cb0096763bb5dba31ea2f4a3e66898df998683a6d3cca8"
  end

  depends_on "rust" => :build

  on_linux do
    depends_on "protobuf" => :build
    depends_on "libdrm"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", "--target-dir", buildpath/"target", *std_cargo_args
    man1.install "docs/man/all-smi.1"

    return unless OS.linux?

    system "cargo", "build", "--release", "--locked", "--lib",
           "--target-dir", buildpath/"target", "--package", "all-smi-amd-plugin"
    (lib/"all-smi").install "target/release/liball_smi_amd.so"
  end

  service do
    run [opt_bin/"all-smi", "api"]
    keep_alive true
    log_path var/"log/all-smi.log"
    error_log_path var/"log/all-smi.log"
    process_type :background
  end

  test do
    assert_match "all-smi #{version}", shell_output("#{bin}/all-smi --version")

    system bin/"all-smi", "--config", testpath/"config.toml", "config", "init"
    assert_path_exists testpath/"config.toml"

    output = shell_output("#{bin}/all-smi --config #{testpath}/config.toml config print")
    assert_match "schema_version = 1", output
    assert_match "default_mode", output
  end
end
