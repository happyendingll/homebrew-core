class MimoCode < Formula
  desc "AI coding agent with cross-session memory"
  homepage "https://github.com/XiaomiMiMo/MiMo-Code"
  url "https://github.com/XiaomiMiMo/MiMo-Code/archive/refs/tags/v0.1.16.tar.gz"
  sha256 "dff948e338bf58e7d580a18fc6385f6669c66512e001fa8e08113280d4cab6a6"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "60253a7d9518a3e96e0fa0d2d4d60be65d305c347dd67c86bf65d2f6111c5548"
  end

  depends_on "bun" => :build
  depends_on "python@3.15" => :build # for node-gyp
  depends_on "ripgrep"

  on_linux do
    depends_on "icu4c@79"
  end

  def install
    ENV["MIMOCODE_VERSION"] = version.to_s
    ENV["MIMOCODE_CHANNEL"] = "latest"

    # The build refuses any Bun other than the exact `packageManager` pin, so pin the brewed one
    bun_version = Formula["bun"].version
    inreplace "package.json", /"packageManager": "bun@[\d.]+"/, "\"packageManager\": \"bun@#{bun_version}\""

    system "bun", "install", "--frozen-lockfile"

    cd "packages/cli" do
      system "bun", "--bun", "./script/build.ts", "--single", "--skip-install"
      bin.install Pathname.pwd.glob("dist/mimocode-*/bin/mimo").first
    end
  end

  test do
    ENV["MIMOCODE_DISABLE_AUTOUPDATE"] = "1"
    ENV["MIMOCODE_DISABLE_MODELS_FETCH"] = "1"

    assert_match version.to_s, shell_output("#{bin}/mimo --version")
    assert_match "mimo", shell_output("#{bin}/mimo models")
  end
end
