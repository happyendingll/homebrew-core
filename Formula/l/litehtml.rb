class Litehtml < Formula
  desc "Fast and lightweight HTML/CSS rendering engine"
  homepage "http://www.litehtml.com/"
  url "https://github.com/litehtml/litehtml/archive/refs/tags/v0.10.tar.gz"
  sha256 "7700eced92847d34ad9846b138cf195a9c974b519be70de58797880ae9da649e"
  license "BSD-3-Clause"
  revision 1
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "cba2d515d02daace4c1c8fe080f98ad19cdd58d0b4f9b6bb063fd7dec6cb666c"
  end

  depends_on "cmake" => :build
  depends_on "gumbo-parser"

  deny_network_access!

  def install
    rm_r("src/gumbo")
    # FIXME: gumbo-parser doesn't have a CMake configuration file or module
    inreplace "cmake/litehtmlConfig.cmake", /^find_dependency\(gumbo\)$/, ""

    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DEXTERNAL_GUMBO=ON",
                    "-DLITEHTML_BUILD_TESTING=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <cassert>
      #include <litehtml.h>

      int main(void) {
        litehtml::css_selector selector;
        assert(selector.parse("[attribute=value]", litehtml::no_quirks_mode));
        const litehtml::css_element_selector &el = selector.m_right;
        assert(el.m_tag == litehtml::star_id);
        assert(el.m_attrs.size() == 1);
        assert(el.m_attrs[0].type == litehtml::select_attr);
        assert(el.m_attrs[0].matcher == litehtml::attribute_equals);
        assert(el.m_attrs[0].name == litehtml::_id("attribute"));
        assert(el.m_attrs[0].value == "value");
        return 0;
      }
    CPP

    system ENV.cxx, "-std=c++17", "test.cpp", "-o", "test", "-I#{include}/litehtml", "-L#{lib}", "-llitehtml"
    system "./test"
  end
end
