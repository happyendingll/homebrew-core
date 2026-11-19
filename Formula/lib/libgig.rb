class Libgig < Formula
  desc "Library for Gigasampler and DLS (Downloadable Sounds) Level 1/2 files"
  homepage "https://www.linuxsampler.org/libgig/"
  url "https://download.linuxsampler.org/packages/libgig-4.6.1.tar.bz2"
  sha256 "961e0fa8b306443d41b1ebbd2c6e4e9d8fb4db850450f80785c4d4590f12d8ca"
  license "GPL-2.0-or-later"

  # Using HTTP rather than HTTPS to avoid SSL connection timeout
  livecheck do
    url "http://download.linuxsampler.org/packages/"
    regex(/href=.*?libgig[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "ad86f235ea2105209402c6a025692ab5586be0d9cf9b206761919f0f7e78c4eb"
  end

  depends_on "pkgconf" => :build
  depends_on "libsndfile"

  on_linux do
    depends_on "e2fsprogs"
    depends_on "util-linux"
  end

  deny_network_access!

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <libgig/gig.h>
      #include <iostream>
      using namespace std;

      int main()
      {
        cout << gig::libraryName() << endl;
        return 0;
      }
    CPP
    args = %W[
      -L#{lib}/libgig
      -lgig
    ]
    args << "-Wl,-rpath,#{lib}/libgig" unless OS.mac?
    system ENV.cxx, "-std=c++11", "test.cpp", *args, "-o", "test"
    assert_match "libgig", shell_output("./test")
  end
end
