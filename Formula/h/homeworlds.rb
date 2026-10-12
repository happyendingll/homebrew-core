class Homeworlds < Formula
  desc "C++ framework for the game of Binary Homeworlds"
  homepage "https://github.com/Quuxplusone/Homeworlds/"
  url "https://github.com/Quuxplusone/Homeworlds/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "3ffbad58943127850047ef144a572f6cc84fd1ec2d29dad1f118db75419bf600"
  license "BSD-2-Clause"
  revision 5
  version_scheme 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "e76a7529f20a47cb5535f533676b5d7eac9d11fed24003f41cced90605edf98c"
  end

  depends_on "wxwidgets"

  # Fix missing `#include`.
  patch do
    url "https://github.com/Quuxplusone/Homeworlds/commit/bb1a5d2395df4e097122b311c0009801107f4d3a.patch?full_index=1"
    sha256 "a133fb4bdeb4a5d2759a7257989089402e0ad84edbaed86780c26d47e58b8d55"
    type :unofficial
    resolves "https://github.com/Quuxplusone/Homeworlds/pull/6"
  end

  def install
    system "make", "homeworlds-cli", "homeworlds-wx"
    bin.install "homeworlds-cli", "homeworlds-wx"
  end

  test do
    output = shell_output(bin/"homeworlds-cli", 1)
    assert_match "Error: Incorrect command-line arguments", output
  end
end
