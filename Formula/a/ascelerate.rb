class Ascelerate < Formula
  desc "Command-line tool for the App Store Connect API"
  homepage "https://ascelerate.dev"
  url "https://github.com/keremerkan/ascelerate/archive/refs/tags/v0.26.4.tar.gz"
  sha256 "a0a4ab8f18257d727b162a2a17a8567a5641597172d7636a248e7d480e5998b9"
  license "MIT"
  head "https://github.com/keremerkan/ascelerate.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "0fb6ffac3e063c1b6e4a19de0a5c405d7a3215c9d71256f51679c8b1350101b6"
    sha256 arm64_tahoe:       "aa8c0f6a4e5e0117e6f7ec48f37a4841b62dea60f45ed9ff93b7d8e62488c98d"
    sha256 arm64_sequoia:     "2eb78c88c5b06449426e72a5bdd4b21da57ad44bb04c5fdb8a4b7b02ca2f30c5"
  end

  depends_on xcode: ["26.0", :build]
  depends_on macos: :sequoia

  deny_network_access!

  def fetch
    # SwiftPM tries to apply its own sandbox, which cannot nest inside the
    # build sandbox; Homebrew's sandbox still confines the whole process.
    system "swift", "package", "resolve", "--disable-sandbox"
  end

  def install
    # The generated App Store Connect client is one large module: optimizing it takes about 17 GB
    # of compiler memory, without optimization about 9 GB. The commands spend their time on the
    # network, so the unoptimized build runs as fast.
    system "swift", "build", *std_swift_args, "--product", "ascelerate", "-Xswiftc", "-Onone"
    bin.install ".build/release/ascelerate"
    generate_completions_from_executable(bin/"ascelerate", "--generate-completion-script")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ascelerate version")
    assert_match "No configuration found", shell_output("#{bin}/ascelerate apps list 2>&1", 1)

    system bin/"ascelerate", "screenshot", "create-helper", "-o", testpath/"ScreenshotHelper.swift", "-y"
    assert_match "ScreenshotHelperVersion", (testpath/"ScreenshotHelper.swift").read
  end
end
