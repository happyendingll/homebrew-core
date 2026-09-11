class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.65.tar.gz"
  sha256 "c132e318a691ed6ec1ce37f063f63aa0291f23415946e41647c5227180f176b3"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "34d70fdbae9a7367f8d29ad8d1a8b42f2b14a0c0bf8a71e1e0831346fe3cc8c2"
    sha256 arm64_tahoe:       "07c3353b2d6d02a49cf180b308786c16c0f7ea011c6d871e9316443da9440f62"
    sha256 arm64_sequoia:     "1c93757cae897eb438633c2a6a5d369356707af38368bd4ca7333d24e66d0e1f"
    sha256 arm64_linux:       "9ff11f99bfdf633318f7bed568f44d06738e7bd08d2b928c3d1fe3de649691d9"
    sha256 x86_64_linux:      "f882778ff3373be2a17491c67f276311b21f8b2022d85e4d9328ab40a93fb55e"
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
