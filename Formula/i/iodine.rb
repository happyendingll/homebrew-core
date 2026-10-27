class Iodine < Formula
  desc "Tunnel IPv4 traffic through a DNS server"
  homepage "https://code.kryo.se/iodine"
  url "https://github.com/yarrick/iodine/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "0294de30815abaacdc1cc5ce0539a3214a902c4f7d93d6fbabee7a0ef5cc5239"
  license "ISC"
  head "https://github.com/yarrick/iodine.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "a61bb68d9c578adfbebf9a0402a1350f38228aa47f33e55460a5c04153a34a2c"
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
