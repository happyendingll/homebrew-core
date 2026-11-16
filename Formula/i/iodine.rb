class Iodine < Formula
  desc "Tunnel IPv4 traffic through a DNS server"
  homepage "https://code.kryo.se/iodine"
  url "https://github.com/yarrick/iodine/archive/refs/tags/v0.9.1.tar.gz"
  sha256 "9c1017dc9ede3a4300ce3026d98b502897e76ae93072ae5045d97b169516f84b"
  license "ISC"
  head "https://github.com/yarrick/iodine.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "0324877e5391498da8d88b18b236be226662aac72113249c593b2f480966a4fc"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    # Both executables require root.
    shell_output("#{sbin}/iodine google.com 2>&1", 255)
    shell_output("#{sbin}/iodined 10.0.0.1 google.com 2>&1", 255)
  end
end
