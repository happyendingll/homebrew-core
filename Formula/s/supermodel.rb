class Supermodel < Formula
  desc "Sega Model 3 arcade emulator"
  homepage "https://github.com/trzy/Supermodel"
  url "https://github.com/trzy/Supermodel/archive/refs/tags/v0.3a-20261014-git-aa8ec00.tar.gz"
  version "0.3a-20261014-git-aa8ec00"
  sha256 "9ae47acd98fd5d3c51ecfab1b9eeb5f28b390c1d1c48b22368e6e531fb920ff5"
  license "GPL-3.0-or-later"
  head "https://github.com/trzy/Supermodel.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "bf498d072433eb240b1462a9b178b00e7ead492c96ee8d240221e819ec2fa482"
    sha256 cellar: :any, arm64_tahoe:       "dbc7467226e5c5a2dd0fe52e2f73f56d9e66aaaa510db77d67dcb36cc3f20a32"
    sha256 cellar: :any, arm64_sequoia:     "c77a08ddbe91dc5d65f3921ab105b417ecf0b1888e94566f283e49a8add444fc"
    sha256 cellar: :any, arm64_linux:       "d770feb647d8352e7f780bf070d4cb0c70984843665191fbf33dd60f7abfc210"
    sha256 cellar: :any, x86_64_linux:      "7001649e8859d7742038ee9b37d2b77bda2d5ddaff5bd940466cd805a2f47e21"
  end

  depends_on "sdl2-compat"
  depends_on "sdl2_net"

  on_linux do
    depends_on "mesa"
    depends_on "mesa-glu"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    # Not using Makefile.OSX as it uses prebuilt frameworks
    system "make", "-f", "Makefiles/Makefile.UNIX", "BIN_DIR=#{bin}"
  end

  test do
    system bin/"supermodel", "-print-games"
  end
end
