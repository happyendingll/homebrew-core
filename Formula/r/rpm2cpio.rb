class Rpm2cpio < Formula
  desc "Tool to convert RPM package to CPIO archive"
  homepage "https://ports.freebsd.org/cgi/ports.cgi?stype=pkg&query=archivers%2frpm2cpio"
  url "https://raw.githubusercontent.com/freebsd/freebsd-ports/c72df716d4887488b758ffe09d763d5127682353/archivers/rpm2cpio/files/rpm2cpio"
  version "1.4"
  sha256 "2841bacdadde2a9225ca387c52259d6007762815468f621253ebb537d6636a00"
  license "BSD-2-Clause"
  compatibility_version 1

  livecheck do
    url "https://raw.githubusercontent.com/freebsd/freebsd-ports/refs/heads/main/archivers/rpm2cpio/Makefile"
    regex(/^PORTVERSION=\s*?v?(\d+(?:\.\d+)+)$/i)
  end

  no_autobump! because: :incompatible_version_format

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "9d6c39d0e2c0795867dfdc424258fc26b3a8a75b568c935b83838da8fa8bf5bb"
  end

  depends_on "libarchive"
  depends_on "xz"

  conflicts_with "rpm", because: "both install `rpm2cpio` binaries"

  resource "homebrew-testdata", :test do
    url "https://github.com/github/gh-ost/releases/download/v1.1.7/gh-ost-1.1.7-1.x86_64.rpm"
    sha256 "9e7c91d07ccae51c653252b8c58c148032f3785223bfa8e531eba81aa912b71a"
  end

  deny_network_access!

  def install
    inreplace "rpm2cpio", "tar", formula_opt_bin("libarchive")/"bsdtar"
    bin.install "rpm2cpio"
  end

  test do
    testpath.install resource "homebrew-testdata"
    system bin/"rpm2cpio", "gh-ost-1.1.7-1.x86_64.rpm"
  end
end
