class Gromacs < Formula
  desc "Versatile package for molecular dynamics calculations"
  homepage "https://www.gromacs.org/"
  url "https://ftp.gromacs.org/pub/gromacs/gromacs-2026.4.tar.gz"
  sha256 "58eda60979b124fcf9dff8b1b63cedfbc72fdb36d99e921dc1bdc310571098b6"
  license "LGPL-2.1-or-later"

  livecheck do
    url "https://ftp.gromacs.org/pub/gromacs/"
    regex(/href=.*?gromacs[._-]v?(\d+(?:\.\d+)*)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "5569ae5ab102b138189ebfff2ce2e8dcd848aed2e5eb27a26273c4e581656bef"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "fftw"
  depends_on "lmfit"
  depends_on "muparser"
  depends_on "openblas"

  on_macos do
    depends_on "libomp"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    # Non-executable GMXRC files should be installed in DATADIR
    inreplace "scripts/CMakeLists.txt", "CMAKE_INSTALL_BINDIR",
                                        "CMAKE_INSTALL_DATADIR"
    # Completion workaround
    inreplace "scripts/GMXRC.bash.cmakein", "$GMXBIN/gmx-completion", bash_completion/"gmx-completion"

    # Avoid superenv shim reference
    cc = DevelopmentTools.locate(ENV.cc)
    cxx = DevelopmentTools.locate(ENV.cxx)

    inreplace "src/gromacs/gromacs-hints.in.cmake" do |s|
      s.gsub! "@CMAKE_LINKER@", "/usr/bin/ld"
      s.gsub! "@CMAKE_C_COMPILER@", cc
      s.gsub! "@CMAKE_CXX_COMPILER@", cxx
    end

    inreplace "src/buildinfo.h.cmakein" do |s|
      s.gsub! "@BUILD_C_COMPILER@", cc
      s.gsub! "@BUILD_CXX_COMPILER@", cxx
    end

    inreplace "src/gromacs/gromacs-config.cmake.cmakein", "@GROMACS_CXX_COMPILER@", cxx

    gmx_simd = if Hardware::CPU.arm?
      "ARM_NEON_ASIMD"
    else
      "SSE2"
    end

    args = %W[
      -DGMX_VERSION_STRING_OF_FORK=#{tap.user}
      -DGMX_INSTALL_LEGACY_API=ON
      -DGMX_EXTERNAL_ZLIB=ON
      -DGMX_USE_LMFIT=EXTERNAL
      -DGMX_USE_MUPARSER=EXTERNAL
      -DGMX_SIMD=#{gmx_simd}
      -DGMX_USE_RDTSCP=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    bash_completion.install bin/"gmx-completion-gmx.bash" => "gmx-completion-gmx.bash"
    bash_completion.install bin/"gmx-completion.bash" => "gmx-completion.bash"
    bash_completion.install "build/scripts/GMXRC.bash" => "gromacs"
    zsh_completion.install "build/scripts/GMXRC.zsh" => "_gromacs"
  end

  def caveats
    <<~EOS
      GMXRC and other scripts installed to:
        #{HOMEBREW_PREFIX}/share/gromacs
    EOS
  end

  test do
    system bin/"gmx", "help"
  end
end
