class SwiftFormat < Formula
  desc "Formatting technology for Swift source code"
  homepage "https://github.com/swiftlang/swift-format"
  url "https://github.com/swiftlang/swift-format.git",
      tag:      "604.0.0",
      revision: "15d7877c6b32926948f6520f0156657945955ea3"
  license "Apache-2.0"
  version_scheme 1
  head "https://github.com/swiftlang/swift-format.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "c386fe03c009c911fa230e5f49fdfbdc2841501ef0b7c8179ac3b219a6944c23"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  pour_bottle? only_if: :clt_installed

  uses_from_macos "swift" => :build

  on_macos do
    depends_on xcode: ["14.0", :build]
  end

  def install
    system "swift", "build", "--product", "swift-format", *std_swift_args
    bin.install ".build/release/swift-format"
    doc.install "Documentation/Configuration.md"
    generate_completions_from_executable(bin/"swift-format", "--generate-completion-script")
  end

  test do
    (testpath/"test.swift").write " print(  \"Hello, World\"  ) ;"
    assert_equal "print(\"Hello, World\")\n", shell_output("#{bin}/swift-format test.swift")
  end
end
