class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.51.tar.gz"
  sha256 "afec5549ecc5c20f7d9f83b96e2a4d53ebdd9675424e3d2e863481e2e9c61ea9"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_tahoe:   "56beaeaef0354cf8147607a3a55d679e9d44f3fa48216fe2dc33e20029d18dce"
    sha256 arm64_sequoia: "4a616585b79b17bf01ad9a5872fc4c4d9492e37168ed43ead416019490f5b603"
    sha256 arm64_sonoma:  "999589b744ef4e24ecabd502f4a4e94c6013f1e508ade65f7de20cd1ced445ca"
    sha256 arm64_linux:   "909cbe550899f6e3b5de55191ce3364f7313f710deee4398bf7ce531b53cab0b"
    sha256 x86_64_linux:  "eb35639b0d4408c74d7a6947fda71d282629f028cbeed837ed6b1f4179c51357"
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
