class Libnpupnp < Formula
  desc "C++ base UPnP library, derived from Portable UPnP, a.k.a libupnp"
  homepage "https://www.lesbonscomptes.com/upmpdcli/npupnp-doc/libnpupnp.html"
  url "https://www.lesbonscomptes.com/upmpdcli/downloads/libnpupnp-6.3.2.tar.gz"
  sha256 "eedf9d9d05d048f88200d5226db065c16f7dcc2e3baefb0fed823185fa3fc024"
  license "BSD-3-Clause"
  compatibility_version 1
  head "https://framagit.org/medoc92/npupnp.git", branch: "master"

  livecheck do
    url "https://www.lesbonscomptes.com/upmpdcli/downloads/"
    regex(/href=.*?libnpupnp[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "2fd6821ba50c46a93cffbf30263d4533d559ca2fb7aab5533c9f6e1a6757d49e"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "libmicrohttpd"

  uses_from_macos "curl"
  uses_from_macos "expat"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
    pkgshare.install "test/test_init.cpp"
  end

  test do
    system ENV.cxx, "-std=c++17", pkgshare/"test_init.cpp", "-o", "test",
                    "-I#{include}/npupnp", "-L#{lib}", "-lnpupnp"
    output = shell_output("./test")
    assert_match "NPUPNP_VERSION_STRING = \"#{version}\"", output
    assert_match "UPnP Initialized OK", output
  end
end
