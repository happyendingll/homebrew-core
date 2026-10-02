class Biosig < Formula
  desc "Tools for biomedical signal processing and data conversion"
  homepage "https://biosig.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/biosig/BioSig%20for%20C_C%2B%2B/src/biosig-3.9.8.src.tar.xz"
  sha256 "9d7298cb6e466eb3b9eb7f4c8bc501dc4c3a71dcdf2f4156bad0ca9797220422"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    regex(%r{url=.*?/(?:biosig|biosig4c[^-]*?)[._-]v?(\d+(?:\.\d+)+)\.src\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "313ef1b658fbea629ad3201a036f180b46bcc0e75d0589339b1236eb9a6df84a"
  end

  depends_on "gawk" => :build
  depends_on "libb64" => :build
  depends_on "dcmtk"
  depends_on "suite-sparse"

  def install
    ENV.append "CXX", "-std=gnu++17"

    # Work around header include order causing issues with `#ifndef isfinite`
    ENV.append "CXXFLAGS", "-include cmath" if DevelopmentTools.clang_build_version >= 1700

    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1403

    # `string_isutf8.o` is missing from the libgdf link target
    inreplace "biosig4c++/Makefile.in",
              "gdf.o gdftime.o physicalunits.o getlogin.o",
              "gdf.o gdftime.o physicalunits.o getlogin.o string_isutf8.o"

    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    ENV.deparallelize if OS.mac? && MacOS.version >= :sonoma
    system "make", "install"
  end

  test do
    assert_match "usage: save2gdf [OPTIONS] SOURCE DEST", shell_output("#{bin}/save2gdf -h").strip
    assert_match "mV\t4274\t0x10b2\t0.001\tV", shell_output("#{bin}/physicalunits mV").strip
    assert_match "biosig_fhir provides fhir binary template for biosignal data",
                 shell_output("#{bin}/biosig_fhir 2>&1").strip
  end
end
