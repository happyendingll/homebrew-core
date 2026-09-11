class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.64.tar.gz"
  sha256 "1fe1250069906969d003686c75592375e82894c636eb2755ed604afa06e5f36a"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "26dc4d057b9874f25efb683906c7bfb1d089b58e95ae45c87f11c66b09b31e28"
    sha256 arm64_tahoe:       "7ccaf1540a26e84851b66cee4d33cdfc088e6cdf6324524cbf8f39aa15037583"
    sha256 arm64_sequoia:     "db9887d804a23a149bf7d4a5551293a251862f1e856541b0c8721e6208a5bb05"
    sha256 arm64_linux:       "16f7777097d3e6224c749ab1138fac8e760df13cb8d2584aa9204acb5fa68f70"
    sha256 x86_64_linux:      "59b56e09e7c96257f4874762e1a0df6c73a8e1eaa4a81855dcd2d8843f4efad4"
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
