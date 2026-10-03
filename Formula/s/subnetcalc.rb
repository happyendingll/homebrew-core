class Subnetcalc < Formula
  desc "IPv4/IPv6 subnet calculator"
  homepage "https://www.nntb.no/~dreibh/subnetcalc/index.html"
  url "https://github.com/dreibh/subnetcalc/archive/refs/tags/subnetcalc-2.7.6.tar.gz"
  sha256 "a0b3adb6b32b0b571d64dcf164278686de7bd1cb52b38aa1849c7e6121109210"
  license "GPL-3.0-or-later"
  head "https://github.com/dreibh/subnetcalc.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "c8fc29dfde3ceeec6a120221dcc22cc94c08dcd20575889b886649c4876ff15b"
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "libidn2"
  depends_on "libmaxminddb"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    expected = <<~EOS
      Address        = 1.1.1.1
                          \e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m1\e[0m . \e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m1\e[0m . \e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m1\e[0m . \e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m0\e[0m\e[34m1\e[0m
      Network        = 1.1.1.1 / 32
      Netmask        = 255.255.255.255
      Broadcast      = not needed on Point-to-Point links
      Wildcard Mask  = 0.0.0.0
      Hex. Address   = 01010101
      Host Bits      = 0
      Max. Hosts     = 1   (2^0 - 0)
      Host Range     = { 1.1.1.1 - 1.1.1.1 }
      Properties     = \

         - 1.1.1.1 is a HOST address in 1.1.1.1/32
         - Class A
      DNS Hostname   = one.one.one.one
    EOS
    assert_equal expected, shell_output("#{bin}/subnetcalc 1.1.1.1/32")
  end
end
