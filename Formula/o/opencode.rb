class Opencode < Formula
  desc "AI coding agent, built for the terminal"
  homepage "https://opencode.ai"
  url "https://github.com/anomalyco/opencode/archive/refs/tags/v2.1.2.tar.gz"
  sha256 "a99505d27899664c4d0778ac40b8589401fbc2256ed56389ca70ee120c5047bb"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    throttle days: 1
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "9452e468f3d6daed8c93a9b5574e912f8cb012ba2ba9f61f2c05bb3440b14607"
  end

  depends_on "bun" => :build
  depends_on "python@3.15" => :build
  depends_on "rust" => :build
  depends_on "zig@0.16" => :build
  depends_on "ripgrep"

  on_linux do
    depends_on "icu4c@78"
  end

  resource "opencode-pty" do
    url "https://github.com/anomalyco/opencode-pty/archive/refs/tags/v0.3.1.tar.gz"
    sha256 "101efcfde719cd9ead649d1fc1e1c31a31e89c854bf63b9cd2e977a7661f18a0"

    livecheck do
      url "https://raw.githubusercontent.com/anomalyco/opencode/refs/tags/v#{LATEST_VERSION}/packages/cli/package.json"
      strategy :json do |json|
        json.dig("dependencies", "@opencode-ai/pty")
      end
    end
  end

  # opencode-pty's build.rs requires a git checkout of the revision in its `ghostty-revision` file
  resource "ghostty" do
    url "https://github.com/ghostty-org/ghostty.git",
        revision: "ab0b9da9e88fcb4b0533a1854e84628f663930af"
    version "ab0b9da9e88fcb4b0533a1854e84628f663930af"

    livecheck do
      url "https://raw.githubusercontent.com/anomalyco/opencode/refs/tags/v#{LATEST_VERSION}/packages/cli/package.json"
      regex(/^(\h{40})$/i)
      strategy :json do |json, regex|
        pty_version = json.dig("dependencies", "@opencode-ai/pty")
        next if pty_version.blank?

        revision_url = "https://raw.githubusercontent.com/anomalyco/opencode-pty/refs/tags/v#{pty_version}/ghostty-revision"
        ghostty_revision = Homebrew::Livecheck::Strategy.page_content(revision_url)[:content]
        next if ghostty_revision.blank?

        ghostty_revision[regex, 1]
      end
    end
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
