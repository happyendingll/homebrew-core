class Kea < Formula
  desc "DHCP server"
  homepage "https://www.isc.org/kea/"
  # NOTE: the livecheck block is a best guess at excluding development versions.
  #       Check https://www.isc.org/download/#Kea to make sure we're using a stable version.
  url "https://downloads.isc.org/isc/kea/3.2.1/kea-3.2.1.tar.xz"
  sha256 "3478220be62b3aa361a2c7f97d5d2989b934f7864e82d4bd17056e1e208b9735"
  license "MPL-2.0"
  head "https://gitlab.isc.org/isc-projects/kea.git", branch: "master"

  livecheck do
    url "https://downloads.isc.org/isc/kea/"
    regex(%r{href=["']?v?(\d+\.\d*[02468](?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "e14510117d263cf9187cbbd96f45866787cc7546a1238de727cb3ec1b2b2ee17"
  end

  depends_on "bison" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.14" => :build
  depends_on "boost" => :no_linkage
  depends_on "log4cplus"
  depends_on "openssl@4"

  deny_network_access!

  def install
    # the build system looks for `sudo` to run some commands, but we don't want to use it
    inreplace "meson.build",
              "SUDO = find_program('sudo', required: false)",
              "SUDO = find_program('', required: false)"

    # Some scripts expect var and etc to be relative paths
    args = %W[
      -Dcpp_std=c++20
      -Dlocalstatedir=#{var.relative_path_from(prefix)}
      -Dsysconfdir=#{etc.relative_path_from(prefix)}
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system sbin/"keactrl", "status"
  end
end
