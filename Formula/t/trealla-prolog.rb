class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.11.10.tar.gz"
  sha256 "f13cd951493411b4952e8a428dd58402c23753dd4683d3314a70a6d471076d82"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  livecheck do
    throttle 5
  end

  bottle do
    sha256 arm64_golden_gate: "131d2fc11da254e4147b29f25b65397bc3752c86e2647d3b8e61d60f8036f3cc"
    sha256 arm64_tahoe:       "5409341c6a93f37e0e7224f02008d275440d95670d4ded7da86a4382a526b3b2"
    sha256 arm64_sequoia:     "e33dc82ab5f44fd737adb09df4ce5ffa9731389ba5d2670ef486fd5d3a5405f6"
    sha256 arm64_linux:       "217ab9142e676582c503437603412c6c6ff6242a9ea473fb5a96f07400052c16"
    sha256 x86_64_linux:      "3997fd00466c996796c64f9b24b912d849de8f6cfe319d8f1c390871ef7cab47"
  end

  depends_on "openssl@4"

  uses_from_macos "libedit"
  uses_from_macos "libffi"

  deny_network_access!

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
