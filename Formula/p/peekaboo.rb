class Peekaboo < Formula
  desc "macOS screen capture, accessibility inspection and UI automation"
  homepage "https://peekaboo.sh/"
  url "https://github.com/openclaw/Peekaboo.git",
      tag:      "v4.9.1",
      revision: "e060b6ba21792b327ce2a10368f57c8e569dc712"
  license "MIT"
  head "https://github.com/openclaw/Peekaboo.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e1696ee9c981b7a9e153f432103904e0066198f5c73bc84cf37346dc22cd0b16"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d43771c1c0e946230d010ef65b52db516322e7fb5318032817b0c827a69e42dc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5dbf1b3e86c80088518c55175f8096be04b7f04208c4dba2321395c1fe6716b3"
  end

  depends_on xcode: ["26.0", :build]
  depends_on macos: :sequoia

  deny_network_access!

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "--package-path", "Apps/CLI", "resolve", "--disable-sandbox"
  end

  def install
    cd "Apps/CLI" do
      system "swift", "build", "--product", "peekaboo", *std_swift_args
      libexec.install ".build/release/peekaboo"
    end

    # The binary links `@rpath/libswiftCompatibilitySpan.dylib`, which macOS 15
    # does not ship. Bundle it beside the binary as upstream does.
    system "xcrun", "swift-stdlib-tool", "--copy", "--scan-executable", libexec/"peekaboo",
           "--platform", "macosx", "--destination", libexec
    deuniversalize_machos libexec/"libswiftCompatibilitySpan.dylib"
    bin.install_symlink libexec/"peekaboo"

    generate_completions_from_executable(bin/"peekaboo", "completions")
  end

  test do
    ENV["PEEKABOO_CONFIG_DIR"] = testpath/".peekaboo"

    assert_match "Peekaboo #{version}", shell_output("#{bin}/peekaboo --version")

    system bin/"peekaboo", "config", "init"
    assert_path_exists testpath/".peekaboo/config.json"
    assert_match "Configuration is valid", shell_output("#{bin}/peekaboo config validate")
  end
end
