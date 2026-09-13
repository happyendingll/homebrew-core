class Swiftformat < Formula
  desc "Formatting tool for reformatting Swift code"
  homepage "https://github.com/nicklockwood/SwiftFormat"
  url "https://github.com/nicklockwood/SwiftFormat/archive/refs/tags/0.63.0.tar.gz"
  sha256 "9a5fc7a8716d7501b3816877e54427f179876de4a7512681f5d9fadc0f70030a"
  license "MIT"
  head "https://github.com/nicklockwood/SwiftFormat.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "3149f38ed57d19d4e0bb9a6e3b0c64f48e1bfc9b7e1708499031b498bcf1bdc9"
  end

  uses_from_macos "swift" => :build

  def install
    system "swift", "build", *std_swift_args
    bin.install ".build/release/swiftformat"
  end

  test do
    (testpath/"potato.swift").write <<~SWIFT
      struct Potato {
        let baked: Bool
      }
    SWIFT
    system bin/"swiftformat", testpath/"potato.swift"
  end
end
