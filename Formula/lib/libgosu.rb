class Libgosu < Formula
  desc "2D game development library"
  homepage "https://libgosu.org"
  url "https://github.com/gosu/gosu/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "5585b759dfffc690f8442dfb1a18434c23f744959cc4f5c2580ffe299efc433d"
  license "MIT"
  head "https://github.com/gosu/gosu.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "a4f90e3c6a80294bdb8f1b7c1bd5b8d62e507502fe85694dd9ff3959c7fc1be8"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "sdl3"

  on_linux do
    depends_on "xorg-server" => :test
    depends_on "fontconfig"
    depends_on "mesa"
  end

  def install
    # GCC rejects `target("neon")` that bundled mojoAL applies to its NEON functions
    ENV.append_to_cflags "-DMOJOAL_FORCE_SCALAR_FALLBACK=1" if OS.linux? && Hardware::CPU.arm?

    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include <stdexcept>
      #include <Gosu/Gosu.hpp>

      class MyWindow : public Gosu::Window
      {
      public:
          MyWindow()
          :   Gosu::Window(640, 480)
          {
              set_caption("Hello World!");
          }

          void update()
          {
              exit(0);
          }
      };

      int main()
      {
          try
          {
              MyWindow window;
              window.show();
          }
          catch (const std::runtime_error& e)
          {
              std::cout << e.what() << std::endl;
              return 1;
          }
      }
    CPP

    system ENV.cxx, "test.cpp", "-o", "test", "-L#{lib}", "-lgosu", "-I#{include}", "-std=c++20"
    if OS.linux?
      # SDL3 fails if no video driver is available and "dummy"
      # workaround doesn't work as libgosu needs OpenGL support in video driver
      IO.pipe do |read_io, write_io|
        pid = spawn(formula_opt_bin("xorg-server")/"Xvfb", "-displayfd", write_io.fileno.to_s, write_io => write_io)
        write_io.close
        ENV["DISPLAY"] = ":#{read_io.read.strip}"
        system "./test"
      ensure
        if pid
          Process.kill "TERM", pid
          Process.wait pid
        end
      end
    else
      # Sandbox blocks access to displays
      assert_match "video driver did not add any displays", shell_output("./test", 1)
    end
  end
end
