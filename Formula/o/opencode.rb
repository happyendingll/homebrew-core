class Opencode < Formula
  desc "AI coding agent, built for the terminal"
  homepage "https://opencode.ai"
  url "https://github.com/anomalyco/opencode/archive/refs/tags/v2.0.20.tar.gz"
  sha256 "e8bc8af7f8f2df976740fc0a3a0564d6d7b34b9389d921ae0007fa2f49c1c236"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    throttle 5
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "e9315a6dd0c7656a9d8f7d741193ca4795217f50c40d4b0aa74c78a3f16ba065"
  end

  depends_on "bun" => :build
  depends_on "python@3.14" => :build
  depends_on "rust" => :build
  depends_on "zig@0.15" => :build
  depends_on "ripgrep"

  on_linux do
    depends_on "icu4c@78"
  end

  # Version must match `@opencode-ai/pty` in packages/cli/package.json
  resource "opencode-pty" do
    url "https://github.com/anomalyco/opencode-pty/archive/refs/tags/v0.1.13.tar.gz"
    sha256 "87f86d91eae5b77f9bc1e3dd76c51f85e8c6ff645a60a373f027943557d8b849"
  end

  # Commit must match `GHOSTTY_COMMIT` in the `libghostty-vt-sys` crate's build.rs
  resource "ghostty" do
    url "https://github.com/ghostty-org/ghostty/archive/a887df42c56f6de86c0fe6da9c4eeca37931e083.tar.gz"
    sha256 "fb4b2f9ffa0af125983041fdbe4ef94d3fa79fb9f2d22b9c213c0e3847a866b6"
  end

  def install
    # Build the persistent PTY helper from source instead of embedding the prebuilt npm binary
    (buildpath/"ghostty").install resource("ghostty")
    ENV["GHOSTTY_SOURCE_DIR"] = buildpath/"ghostty"
    resource("opencode-pty").stage do
      system "cargo", "install", *std_cargo_args(root: buildpath/"opencode-pty")
    end
    ENV["OPENCODE_PTY_BIN"] = buildpath/"opencode-pty/bin/opencode-pty"

    ENV["OPENCODE_VERSION"] = version.to_s
    ENV["OPENCODE_CHANNEL"] = "latest"

    # Fix server errors when building with Bun 1.4.2 by disabling splitting
    # https://github.com/anomalyco/opencode/issues/48645
    # https://github.com/NixOS/nixpkgs/issues/563241
    inreplace "packages/cli/script/build.ts", "splitting: true,", "splitting: false,"

    system "bun", "install", "--frozen-lockfile"

    cd "packages/cli" do
      system "bun", "--bun", "./script/build.ts", "--single", "--skip-install"
      bin.install Pathname.pwd.glob("dist/cli-*/bin/opencode").first
    end

    generate_completions_from_executable(bin/"opencode", "--completions")
  end

  test do
    ENV["OPENCODE_DISABLE_AUTOUPDATE"] = "1"
    ENV["OPENCODE_DISABLE_MODELS_FETCH"] = "1"

    assert_match version.to_s, shell_output("#{bin}/opencode --version")

    (testpath/"opencode.json").write <<~JSON
      { "agent": { "brewtest": { "description": "Homebrew test agent", "prompt": "hi" } } }
    JSON
    # The standalone server listens on localhost, so network access can't be denied here
    entries = JSON.parse(shell_output("#{bin}/opencode api --standalone config.get"))
    project = entries.find { |entry| entry["path"] == (testpath/"opencode.json").realpath.to_s }
    assert_equal "hi", project.dig("info", "agents", "brewtest", "system")
  end
end
