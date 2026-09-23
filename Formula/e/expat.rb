class Expat < Formula
  desc "XML 1.0 parser"
  homepage "https://libexpat.github.io/"
  url "https://github.com/libexpat/libexpat/releases/download/R_2_8_5/expat-2.8.5.tar.xz"
  sha256 "1e727b8933ec51a77a9a9d9afcf8e688bce45d907c13e36ab7393fe36e703182"
  license "MIT"
  compatibility_version 1

  livecheck do
    url :stable
    regex(/^\D*?(\d+(?:[._]\d+)*)$/i)
    strategy :github_latest do |json, regex|
      json["tag_name"]&.scan(regex)&.map { |match| match[0].tr("_", ".") }
    end
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "3cc46d954b9634ae68bb4a4fca433680d6333a0537168bd8a62c7f1b3bb040f5"
  end

  head do
    url "https://github.com/libexpat/libexpat.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "docbook2x" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  deny_network_access!

  def install
    if build.head?
      cd "expat"
      system "./buildconf.sh"
      args = ["--with-docbook"]
    end
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include "expat.h"

      static void XMLCALL my_StartElementHandler(
        void *userdata,
        const XML_Char *name,
        const XML_Char **atts)
      {
        printf("tag:%s|", name);
      }

      static void XMLCALL my_CharacterDataHandler(
        void *userdata,
        const XML_Char *s,
        int len)
      {
        printf("data:%.*s|", len, s);
      }

      int main()
      {
        static const char str[] = "<str>Hello, world!</str>";
        int result;

        XML_Parser parser = XML_ParserCreate("utf-8");
        XML_SetElementHandler(parser, my_StartElementHandler, NULL);
        XML_SetCharacterDataHandler(parser, my_CharacterDataHandler);
        result = XML_Parse(parser, str, sizeof(str), 1);
        XML_ParserFree(parser);

        return result;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lexpat", "-o", "test"
    assert_equal "tag:str|data:Hello, world!|", shell_output("./test")
  end
end
