class Gl2ps < Formula
  desc "OpenGL to PostScript printing library"
  homepage "https://www.geuz.org/gl2ps/"
  url "https://geuz.org/gl2ps/src/gl2ps-1.4.3.tgz"
  sha256 "2e0a5368917cf0e5467ba8618bc576f50ae9f316c61201635b09711c7908efcc"
  license "GL2PS"

  livecheck do
    url "https://geuz.org/gl2ps/src/"
    regex(/href=.*?gl2ps[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "b9bb018b4ba057cfad74baa93fedd560bf5522053d14b26f66d432caff35d688"
  end

  depends_on "cmake" => :build
  depends_on "libpng"

  on_linux do
    depends_on "xorg-server" => :test
    depends_on "freeglut"
    depends_on "mesa"
    depends_on "zlib-ng-compat"
  end

  deny_network_access!
  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    glu = if OS.mac?
      "GLUT"
    else
      "GL"
    end
    (testpath/"test.c").write <<~C
      #include <#{glu}/glut.h>
      #include <gl2ps.h>

      int main(int argc, char *argv[])
      {
        glutInit(&argc, argv);
        glutInitDisplayMode(GLUT_DEPTH);
        glutInitWindowSize(400, 400);
        glutInitWindowPosition(100, 100);
        glutCreateWindow(argv[0]);
        GLint viewport[4];
        glGetIntegerv(GL_VIEWPORT, viewport);
        FILE *fp = fopen("test.eps", "wb");
        GLint buffsize = 0, state = GL2PS_OVERFLOW;
        while( state == GL2PS_OVERFLOW ){
          buffsize += 1024*1024;
          gl2psBeginPage ( "Test", "Homebrew", viewport,
                           GL2PS_EPS, GL2PS_BSP_SORT, GL2PS_SILENT |
                           GL2PS_SIMPLE_LINE_OFFSET | GL2PS_NO_BLENDING |
                           GL2PS_OCCLUSION_CULL | GL2PS_BEST_ROOT,
                           GL_RGBA, 0, NULL, 0, 0, 0, buffsize,
                           fp, "test.eps" );
          gl2psText("Homebrew Test", "Courier", 12);
          state = gl2psEndPage();
        }
        fclose(fp);
        return 0;
      }
    C
    if OS.mac?
      system ENV.cc, "-L#{lib}", "-lgl2ps", "-framework", "OpenGL", "-framework", "GLUT",
                     "-framework", "Cocoa", "test.c", "-o", "test"

      # GLUT needs a WindowServer connection, which the test sandbox denies
      return
    else
      system ENV.cc, "test.c", "-o", "test", "-L#{lib}", "-lgl2ps", "-lglut", "-lGL"
    end
    if OS.linux? && ENV.exclude?("DISPLAY")
      system formula_opt_bin("xorg-server")/"xvfb-run", "./test"
    else
      system "./test"
    end
    assert_path_exists testpath/"test.eps"
    assert_predicate File.size("test.eps"), :positive?
  end
end
