class Openkermit < Formula
  desc "Scriptable network and serial communication for UNIX and VMS"
  homepage "https://www.openkermit.org/"
  url "https://github.com/openkermit/ckermit/archive/refs/tags/v11.0.512.tar.gz"
  sha256 "aa4d269651b91d1a76606fcdc84240e52f9b55d39bad16e987f9625dc21fd07c"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "88de63088b05bc426974fc3242167a8805940905b0ac11875d992c36b6be84a5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "23397a4ef0c269f4e7ebc9ecdae07e8b6b04215d55bceaf6c4f8a754cacc505c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "18d8e2647b290e2c9a4c1c983fa52de192850be5e05764af230965705cf00c2e"
    sha256 cellar: :any,                 arm64_linux:       "d4526df69f41c84a7408fddada55e20caf8751e77933d29c6b25f6b01acde753"
    sha256 cellar: :any,                 x86_64_linux:      "ea50fd5b072fcaa38861beae3fa8966f7f1f38bb9f4b6d8bdbe4684f1dba4596"
  end

  uses_from_macos "libxcrypt"
  uses_from_macos "ncurses"

  def install
    os = OS.mac? ? "macosx" : "linux"
    system "make", os, "KFLAGS=-DCK_NCURSES -I#{formula_opt_include("ncurses")}"

    man1.mkpath

    # The makefile adds /man to the end of manroot when running install
    # hence we pass share here, not man.  If we don't pass anything it
    # uses {prefix}/man
    system "make", "prefix=#{prefix}", "manroot=#{share}", "install"
  end

  test do
    # /confirm:off keeps this headless.
    system "#{bin}/kermit", "-C",
           "set host /network-type:pseudoterminal \"kermit -x\", get /confirm:off /bin/sh, bye, quit"
    assert_path_exists "sh"
  end
end
