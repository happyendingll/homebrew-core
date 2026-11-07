class Chicken < Formula
  desc "Compiler for the Scheme programming language"
  homepage "https://www.call-cc.org/"
  url "https://code.call-cc.org/releases/6.1.0/chicken-6.1.0.tar.gz"
  sha256 "c6aee9a5374102ba318e0cfae62ded5e1825346577137952d7fb15b3094d49d8"
  license "BSD-3-Clause"
  head "https://code.call-cc.org/git/chicken-core.git", branch: "master"

  livecheck do
    url "https://code.call-cc.org/releases/current/"
    regex(/href=.*?chicken[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "ae8558d273347b537513cc4c17f59ec683755dfeeb5f29b4d8f87d81dd1e343e"
  end

  conflicts_with "mono", because: "both install `csc`, `csi` binaries"

  deny_network_access!

  def install
    ENV.deparallelize

    args = %W[
      PREFIX=#{prefix}
      C_COMPILER=#{ENV.cc}
      LIBRARIAN=ar
      ARCH=#{Hardware::CPU.arch.to_s.tr("_", "-")}
      LINKER_OPTIONS=-Wl,-rpath,#{rpath},-rpath,#{HOMEBREW_PREFIX}/lib
    ]

    if OS.mac?
      args << "POSTINSTALL_PROGRAM=install_name_tool"
      args << "PLATFORM=macosx"
    else
      args << "PLATFORM=linux"
    end

    system "make", *args
    system "make", "install", *args
  end

  test do
    assert_equal "25", shell_output("#{bin}/csi -e '(print (* 5 5))'").strip
    system bin/"csi", "-ne", "(import (chicken tcp))"
  end
end
