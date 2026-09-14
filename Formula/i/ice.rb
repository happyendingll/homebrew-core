class Ice < Formula
  desc "Comprehensive RPC framework"
  homepage "https://zeroc.com"
  url "https://github.com/zeroc-ice/ice/archive/refs/tags/v3.8.3.tar.gz"
  sha256 "62240ed349317f72269ebf1b26e8b3629a09ad9a915031e942e83f75e9fb6971"
  # See https://github.com/zeroc-ice/ice/blob/main/ICE_LICENSE for a special
  # exception to combine Ice with the OpenSSL library and Apache-2.0 libraries
  license "GPL-2.0-only"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "f1509ec48d1f31f755493826088110b665bf78ae49088d32466b5c8578fcc82c"
  end

  depends_on "lmdb"
  depends_on "mcpp"

  uses_from_macos "bzip2"
  uses_from_macos "expat"
  uses_from_macos "libedit"
  uses_from_macos "libxcrypt"

  on_linux do
    depends_on "openssl@3"
  end

  def install
    if DevelopmentTools.clang_build_version < 1700
      inreplace "config/Make.rules.Darwin", "-Wl,-max_default_common_align,0x4000", ""
    end

    args = [
      "prefix=#{prefix}",
      "V=1",
      "USR_DIR_INSTALL=yes", # ensure slice and man files are installed to share
      "MCPP_HOME=#{formula_opt_prefix("mcpp")}",
      "LMDB_HOME=#{formula_opt_prefix("lmdb")}",
      "CONFIGS=all",
      "PLATFORMS=all",
      "LANGUAGES=cpp",
    ]
    system "make", "install", *args
  end

  test do
    (testpath/"Hello.ice").write <<~EOS
      module Test
      {
          interface Hello
          {
              void sayHello();
          }
      }
    EOS

    port = free_port

    (testpath/"Test.cpp").write <<~CPP
      #include "Hello.h"
      #include <Ice/Ice.h>

      class HelloI : public Test::Hello
      {
      public:
          void sayHello(const Ice::Current&) override {}
      };

      int main(int argc, char* argv[])
      {
        Ice::CommunicatorHolder ich(argc, argv);
        auto adapter = ich->createObjectAdapterWithEndpoints("Hello", "default -h 127.0.0.1 -p #{port}");
        adapter->add(std::make_shared<HelloI>(), Ice::stringToIdentity("hello"));
        adapter->activate();
        return 0;
      }
    CPP

    system bin/"slice2cpp", "Hello.ice"
    system ENV.cxx, "-std=c++20", "-c", "-I#{include}", "Hello.cpp"
    system ENV.cxx, "-std=c++20", "-c", "-I#{include}", "Test.cpp"
    system ENV.cxx, "-L#{lib}", "-o", "test", "Test.o", "Hello.o", "-lIce", "-lpthread"
    system "./test"
  end
end
