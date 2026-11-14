class MimoCode < Formula
  desc "AI coding agent with cross-session memory"
  homepage "https://github.com/XiaomiMiMo/MiMo-Code"
  url "https://github.com/XiaomiMiMo/MiMo-Code/archive/refs/tags/v0.1.17.tar.gz"
  sha256 "b31dbb1f7ed1fb601778e30ef9b07de65968193937ddbfa42dc783dd4a058e59"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "0dd48235790ed4b3f8ea77dbf678273d0896350f0a2d1503cc76c993943cc281"
  end

  depends_on "bun" => :build
  depends_on "ripgrep"

  uses_from_macos "python" => :build # for node-gyp

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
