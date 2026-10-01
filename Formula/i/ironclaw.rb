class Ironclaw < Formula
  desc "Security-first personal AI assistant with WASM sandbox channels"
  homepage "https://www.ironclaw.com"
  url "https://github.com/nearai/ironclaw/archive/refs/tags/ironclaw-v1.4.1.tar.gz"
  sha256 "1fb826d6ce730a659205f6e60093bb9a79eb02bfd2535b64c9b19bec13ede034"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/nearai/ironclaw.git", branch: "main"

  livecheck do
    url :stable
    regex(/^ironclaw-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "6e699156bf5498472135b9c7d3de35324c51f238446d053e3c97387f4d3198bf"
  end

  depends_on "corepack" => :build
  depends_on "node" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :build

  def install
    ENV["COREPACK_ENABLE_DOWNLOAD_PROMPT"] = "0"

    system "cargo", "install", *std_cargo_args(path: "crates/app/ironclaw_cli")
  end

  service do
    run [opt_bin/"ironclaw", "serve"]
    keep_alive true
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ironclaw --version")

    ENV["IRONCLAW_REBORN_HOME"] = testpath/"home"
    assert_match "IronClaw Reborn config", shell_output("#{bin}/ironclaw config list")
  end
end
