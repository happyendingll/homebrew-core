class KanataTray < Formula
  desc "System tray for kanata keyboard remapper"
  homepage "https://github.com/rszyma/kanata-tray"
  url "https://github.com/rszyma/kanata-tray/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "b7541d686dcabbdbeee4ad78b8eabc2092260be93dc3455a51263f42399eac00"
  license "GPL-3.0-or-later"
  head "https://github.com/rszyma/kanata-tray.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "eac095f1802230e064e7753648bf8d6d38dcc3e59195b17fed877356e51be318"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build

  on_linux do
    depends_on "glib"
    depends_on "gtk+3"
    depends_on "libayatana-appindicator"
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Workaround to avoid patchelf corruption when cgo is required
    if OS.linux? && Hardware::CPU.arm64?
      ENV["CGO_ENABLED"] = "1"
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    ldflags = " -X main.buildVersion=#{version} -X main.buildHash=#{tap.user} -X main.buildDate=#{time.iso8601}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    ENV["KANATA_TRAY_LOG_DIR"] = testpath

    assert_match version.to_s, shell_output("#{bin}/kanata-tray --version 2>&1", 1)

    with_test_process(bin/"kanata-tray") do
      sleep 2
      assert_match "Creating it and populating with the default icons", (testpath/"kanata_tray_lastrun.log").read
    end
  end
end
