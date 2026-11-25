class Libupnpp < Formula
  desc "C++ wrapper for libnpupnp"
  homepage "https://www.lesbonscomptes.com/upmpdcli/libupnpp-refdoc/libupnpp-ctl.html"
  url "https://www.lesbonscomptes.com/upmpdcli/downloads/libupnpp-1.0.5.tar.gz"
  sha256 "f83da1bfde4823bb079ce228a2c9abd695274ae572758dbb02159184db150dd0"
  license "LGPL-2.1-or-later"
  head "https://framagit.org/medoc92/libupnpp.git", branch: "master"

  livecheck do
    url "https://www.lesbonscomptes.com/upmpdcli/downloads/"
    regex(/href=.*?libupnpp[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "7e3c4eb4a05ab256c0f6a9a483b3a1fdf41b39767cd608f220445d68ceff7a18"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "libnpupnp"

  uses_from_macos "curl"
  uses_from_macos "expat"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include <libupnpp/log.hxx>
      #include <libupnpp/upnpplib.hxx>

      int main(void) {
        Logger::getTheLog("")->setLogLevel(Logger::LLERR);
        UPnPP::LibUPnP *mylib = UPnPP::LibUPnP::getLibUPnP();
        if (!mylib) {
          std::cerr << "Can't get LibUPnP" << std::endl;
          return 1;
        }
        if (!mylib->ok()) {
          std::cerr << "Lib init failed: " << mylib->errAsString("main", mylib->getInitError()) << std::endl;
          return 1;
        }
        return 0;
      }
    CPP

    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test", "-L#{lib}", "-lupnpp"
    system "./test"
  end
end
