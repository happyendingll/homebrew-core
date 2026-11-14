class Asymptote < Formula
  desc "Powerful descriptive vector graphics language"
  homepage "https://asymptote.sourceforge.io"
  # Keep version in sync with manual below
  url "https://downloads.sourceforge.net/project/asymptote/3.16/asymptote-3.16.src.tgz"
  sha256 "3755e8f3776a3d494354964ba0109203eece417ccd8ac8f5479932514cb30e1b"
  license "LGPL-3.0-only"

  livecheck do
    url :stable
    regex(%r{url=.*?/asymptote[._-]v?(\d+(?:\.\d+)+)\.src\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 sequoia: "c33efd58d7fe7f3571c229d75f578bef48ec355046602e8decbde18a3ab2fc9b"
  end

  depends_on "cmake" => :build
  depends_on "glm" => :build
  depends_on "pkgconf" => :build
  depends_on "vulkan-headers" => :build
  depends_on "bdw-gc"
  depends_on "fftw"
  depends_on "ghostscript"
  depends_on "glfw"
  depends_on "glslang"
  depends_on "gsl"
  depends_on "readline"
  depends_on "spirv-tools"
  depends_on "vulkan-loader"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "ncurses"

  on_macos do
    depends_on "molten-vk"
  end

  on_linux do
    depends_on "libtool" => :build
    depends_on "freeglut"
    depends_on "libtirpc"
    depends_on "mesa"
    depends_on "zlib-ng-compat"
  end

  resource "manual" do
    url "https://downloads.sourceforge.net/project/asymptote/3.16/asymptote.pdf"
    sha256 "ea1f2a5af6963da29cf77aa52b1280e29396fe2c9fda11a4cd4049440f3bbf82"

    livecheck do
      formula :parent
    end
  end

  deny_network_access!

  def install
    odie "manual resource needs to be updated" if version != resource("manual").version

    # Homebrew glslang is a unified shared lib; these split component libs don't exist
    inreplace "configure", 'VULKAN_LIBS="-lMachineIndependent -lOSDependent -lGenericCodeGen "', 'VULKAN_LIBS=""'

    system "./configure", *std_configure_args

    # Avoid use of LaTeX with these commands (instead of `make all && make install`)
    # Also workaround to override bundled bdw-gc. Upstream is not willing to add configure option.
    # Ref: https://github.com/vectorgraphics/asymptote/issues/521#issuecomment-2644549764
    touch "doc/asy-latex.pdf"
    system "make", "install-asy", "GCLIB=#{formula_opt_lib("bdw-gc")/shared_library("libgc")}"

    doc.install resource("manual")
    elisp.install_symlink pkgshare.glob("*.el")
  end

  test do
    (testpath/"line.asy").write <<~EOF
      settings.outformat = "pdf";
      size(200,0);
      draw((0,0)--(100,50),N,red);
    EOF

    system bin/"asy", testpath/"line.asy"
    assert_path_exists testpath/"line.pdf"
  end
end
