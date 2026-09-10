class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.55.tar.gz"
  sha256 "6e907cb03c96199a5353d0c684abd783a3464d8bef815ad3bca0b371cf44dc57"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_tahoe:   "224f7bea65827bab46ef869ecc6ca86ed9a0d81c55a9e0bafa96ab4ba2ecf342"
    sha256 arm64_sequoia: "1db1ed7967d42a3271e127442ad373a7d26b2f445b0316ea506f36fea0e6eee9"
    sha256 arm64_sonoma:  "1922a7f3f767e533f0064bf7a7e4a8a1556a984af052f5a96609c53eee27d19b"
    sha256 arm64_linux:   "3a3813f0650565d2578a2808513864a59a25f27f840cfe85d1aaab307ef9b8c5"
    sha256 x86_64_linux:  "5d34a63829f7b74838ed150d1d50aa58bfd092c4d4d6fbb376efcdca6ad649b8"
  end

  depends_on "openssl@4"

  uses_from_macos "libedit"
  uses_from_macos "libffi"

  def install
    args = ["PREFIX=#{prefix}", "OPENSSL=openssl@4"]
    # macOS keeps ffi.h in an ffi/ subdirectory, which the build's plain
    # `#include <ffi.h>` misses. TARGET_CFLAGS is the makefile's append hook.
    args << "TARGET_CFLAGS=-I#{MacOS.sdk_path}/usr/include/ffi" if OS.mac?
    system "make", "install", *args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tpl --version")

    assert_equal "42", shell_output("#{bin}/tpl -g 'X is 6*7, write(X), halt'").chomp

    # library(assoc) is not embedded in the binary, so this also proves the
    # installed library path was baked in correctly.
    goal = "use_module(library(assoc)), list_to_assoc([a-1, b-2], A), " \
           "get_assoc(b, A, V), write(V), halt"
    assert_equal "2", shell_output("#{bin}/tpl -g '#{goal}'").chomp
  end
end
