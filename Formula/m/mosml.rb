class Mosml < Formula
  desc "Moscow ML"
  homepage "https://mosml.org/"
  url "https://github.com/kfl/mosml/archive/refs/tags/ver-2.10.1.tar.gz"
  sha256 "fed5393668b88d69475b070999b1fd34e902591345de7f09b236824b92e4a78f"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "dd7b57aa4d9f29ff115a07972d6eaa40e2f8641db272c049d5e355a4ae05ead2"
  end

  depends_on "gmp"

  # Backport missing headers to fix build
  patch do
    url "https://github.com/kfl/mosml/commit/52b00ca99dcd77d64dac5a7600fe64a76ed1ac3a.patch?full_index=1"
    sha256 "e0db36e944b5d60e0e98afd3f3e9463d193ae89b7aa66d2cc7c452c6c6ed8632"
    type :backport
  end

  def install
    # Work around for newer Clang
    ENV.append "CC", "-Wno-implicit-int" if DevelopmentTools.clang_build_version >= 1403

    system "make", "-C", "src", "PREFIX=#{prefix}", "CC=#{ENV.cc}", "world"
    system "make", "-C", "src", "PREFIX=#{prefix}", "CC=#{ENV.cc}", "install"
  end

  test do
    require "pty"

    _, w, = PTY.spawn bin/"mosml"
    w.write "quit();\n"

    assert_equal "I don't know what to do with file \"foo\", ignored", shell_output("#{bin}/mosmlc foo 2>&1").strip
  end
end
