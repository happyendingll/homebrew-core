class Swiftformat < Formula
  desc "Formatting tool for reformatting Swift code"
  homepage "https://github.com/nicklockwood/SwiftFormat"
  url "https://github.com/nicklockwood/SwiftFormat/archive/refs/tags/0.64.5.tar.gz"
  sha256 "6997744f02e79e8e913cc4adb3bf790d5a4c3dce1bcf186234ee9f3cddf09645"
  license "MIT"
  head "https://github.com/nicklockwood/SwiftFormat.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "ddcc718789466f33c896d74e732fa6c53d4e2107c857a136a97eac61361b3890"
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
