class Dcmtk < Formula
  desc "OFFIS DICOM toolkit command-line utilities"
  homepage "https://dcmtk.org/en/dcmtk/", browsed: "2026-08-06"
  license "BSD-3-Clause"
  head "https://git.dcmtk.org/dcmtk.git", branch: "master"

  stable do
    url "https://github.com/DCMTK/dcmtk/archive/refs/tags/DCMTK-3.7.0.tar.gz"
    sha256 "5bb3ec8317dc465788bed2ca789e76d03ae5848c9381cce3b14c1a3f8b6aca56"

    # Backport support for OpenSSL 4
    patch do
      url "https://github.com/DCMTK/dcmtk/commit/2a9060b4b6670ad4db169abeac17728f56b43139.patch?full_index=1"
      sha256 "f36979e5534ff973812505e15daa1666008219cde47f7a040af08a81a3879a04"
      type :backport
    end
  end

  livecheck do
    url :head
    regex(/^dcmtk[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "2812c2a1cda7412f79ea22f70b7cec4596d41ffd3ee6d3fbec726646c807ba59"
  end

  depends_on "cmake" => :build

  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openssl@4"

  uses_from_macos "libxml2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    args = std_cmake_args + ["-DDCMTK_WITH_ICU=OFF"]

    system "cmake", "-S", ".", "-B", "build/shared", *args,
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", "--build", "build/shared"
    system "cmake", "--install", "build/shared"

    system "cmake", "-S", ".", "-B", "build/static", *args,
                    "-DBUILD_SHARED_LIBS=OFF"
    system "cmake", "--build", "build/static"
    lib.install Dir["build/static/lib/*.a"]

    inreplace lib/"cmake/dcmtk/DCMTKConfig.cmake", "#{Superenv.shims_path}/", ""
  end

  test do
    system bin/"pdf2dcm", "--verbose",
           test_fixtures("test.pdf"), testpath/"out.dcm"
    system bin/"dcmftest", testpath/"out.dcm"
  end
end
