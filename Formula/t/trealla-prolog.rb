class TreallaProlog < Formula
  desc "Compact and efficient ISO Prolog interpreter written in plain old C"
  homepage "https://github.com/trealla-prolog/trealla-prolog"
  url "https://github.com/trealla-prolog/trealla-prolog/archive/refs/tags/v3.9.72.tar.gz"
  sha256 "2751974b9425ee23874ca4e7d4a66c3fef4e70ecb9260060f302004bcbb979ac"
  license "MIT"
  head "https://github.com/trealla-prolog/trealla-prolog.git", branch: "main"

  bottle do
    sha256 arm64_golden_gate: "7051dda65a7cb8cffa0260886f4cf4cb7ea5437129d4387cc3a73cd6cf37301e"
    sha256 arm64_tahoe:       "9ef001bf819c04836d2ac69ac01650ca0d8a8c7526f381b38c0cbc201d77629d"
    sha256 arm64_sequoia:     "af6b17868d8e5b1c70dae6ffe90f14ddad5b6c0c9a1771296c942504ca30af49"
    sha256 arm64_linux:       "1b6e5cee1edb680dbff28a8dc8c99b3e44828b59c9cf631e077e90f2c48c3e06"
    sha256 x86_64_linux:      "40d309c03f4cef7f08fb11d235e5a5d5d1ac695bc12a30d3435b86790a21f984"
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
