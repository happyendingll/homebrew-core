class AllSmi < Formula
  desc "GPU monitoring tool for NVIDIA/Jetson/Apple Silicon/Tenstorrent"
  homepage "https://github.com/lablup/all-smi"
  url "https://github.com/lablup/all-smi/archive/refs/tags/v0.29.1.tar.gz"
  sha256 "37ddbd92f52ecfcc756de7fcf2d2f046c361c3caa5c1c67a77f797ee9f989996"
  license "Apache-2.0"
  head "https://github.com/lablup/all-smi.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "1100b44ce288233c61bde5179a3803b9e05d81f85ce8654717657e406cab1d85"
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
