class Hidapitester < Formula
  desc "Command-line tool to exercise USB HID devices via HIDAPI"
  homepage "https://github.com/todbot/hidapitester"
  url "https://github.com/todbot/hidapitester/archive/refs/tags/v0.7.tar.gz"
  sha256 "a20f805e308592f79c9ea4ecf74d9ea36a267e222b3c3c49c18f7b980a67ebbe"
  license "GPL-3.0-only"
  head "https://github.com/todbot/hidapitester.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "e5aa2929aca9d5ce349afb9725414f5216addba836acdcb9b4e50bd71a7b8c88"
  end

  depends_on "cmake" => :build
  depends_on "hidapi"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DHIDAPITESTER_VERSION=v#{version}",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hidapitester --version")

    output = shell_output("#{bin}/hidapitester --vidpid 1234:5678 --open --send-feature 1,2,3,4,5")
    assert_match "Opening device, vid/pid: 0x1234/0x5678", output
    assert_match "Error on send: no device opened", output
  end
end
