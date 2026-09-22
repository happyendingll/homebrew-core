class SnxRs < Formula
  desc "Open-source client for Check Point VPN tunnels"
  homepage "https://github.com/ancwrd1/snx-rs"
  url "https://github.com/ancwrd1/snx-rs/archive/refs/tags/v6.4.0.tar.gz"
  sha256 "bc5d28e164b9a544bfdf02fab9d9cb3c0927ab205476d9909cbed418975ddd70"
  license "AGPL-3.0-only"
  head "https://github.com/ancwrd1/snx-rs.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "6268f1ec7d15679dc4dedd062ade82f8e68102db5a97b9e1f15ba5f76622ccaa"
    sha256 cellar: :any, arm64_tahoe:       "6d68341b0bfb4d44ebc6283b825b50e3243822b080cff9b988d105c12343875f"
    sha256 cellar: :any, arm64_sequoia:     "bdf7c074131d55baf56619c17bd0767a805d46f4a1eae5bb18e9f73242eb680e"
    sha256 cellar: :any, arm64_linux:       "5725f1938f3f1b915295a380dd52791b4ad04c1703c7a17c508dff2eea56376f"
    sha256 cellar: :any, x86_64_linux:      "833d547a746d6284901c492fed16e8be7afe6883fd1ef3712ec1b830f545aa8d"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"

  uses_from_macos "sqlite"

  on_linux do
    depends_on "fontconfig"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "apps/snx-rs")
    system "cargo", "install", *std_cargo_args(path: "apps/snxctl")

    # The GUI uses Slint. On macOS, enable the `mobile-access` feature
    # for the embedded Mobile Access portal login,
    # since it uses the system WebView (no extra dependencies).
    # On Linux that feature would require GTK4/WebKit6, so it is omitted.
    # This matches upstream's macOS build and its default (non-webkit) Linux build.
    gui_args = std_cargo_args(path: "apps/snx-rs-gui")
    gui_args += ["--features", "snx-rs-gui/mobile-access"] if OS.mac?
    system "cargo", "install", *gui_args

    # snxctl exposes completions via a `completions` subcommand;
    # snx-rs and snx-rs-gui via a `--completions` flag.
    generate_completions_from_executable(bin/"snxctl", "completions")
    generate_completions_from_executable(bin/"snx-rs", "--completions")
    generate_completions_from_executable(bin/"snx-rs-gui", "--completions")
  end

  service do
    run [opt_bin/"snx-rs", "-m", "command", "-l", "info"]
    require_root true
    keep_alive crashed: true
    log_path var/"log/snx-rs.log"
    error_log_path var/"log/snx-rs.log"
  end

  test do
    assert_match "VPN client for Check Point security gateway", shell_output("#{bin}/snx-rs --help")

    %w[snx-rs snxctl snx-rs-gui].each do |exe|
      assert_match version.to_s, shell_output("#{bin}/#{exe} --version")
    end

    # Probe localhost (nothing listening) and fail fast without requiring external network.
    assert_match "https://localhost/", shell_output("#{bin}/snx-rs -m info -s localhost 2>&1", 1)
  end
end
