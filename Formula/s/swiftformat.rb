class Swiftformat < Formula
  desc "Formatting tool for reformatting Swift code"
  homepage "https://github.com/nicklockwood/SwiftFormat"
  url "https://github.com/nicklockwood/SwiftFormat/archive/refs/tags/0.64.7.tar.gz"
  sha256 "1ab244207e2d15dbfbe61646be26513fa9060799792fb44ce0a180845fc8d971"
  license "MIT"
  head "https://github.com/nicklockwood/SwiftFormat.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "480f3ac7bfd06bfceb3da108f918a140a4ca5626304a9e87bc69bf99a72b6d13"
  end

  uses_from_macos "swift" => :build

  deny_network_access!

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
