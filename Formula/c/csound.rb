class Csound < Formula
  desc "Sound and music computing system"
  homepage "https://csound.com"
  url "https://github.com/csound/csound.git",
      tag:      "7.0.0",
      revision: "c58f4de6b8056b9356f31615b395b3bfd9bd0775"
  license "LGPL-2.1-or-later"
  head "https://github.com/csound/csound.git", branch: "develop"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "1151873e11803a71c8101a0aefdbcafd044721fac5cdec360c50429034a8bb21"
  end

  depends_on "asio" => :build
  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "gettext"
  depends_on "jack"
  depends_on "lame"
  depends_on "liblo"
  depends_on "libsamplerate"
  depends_on "libsndfile"
  depends_on "portaudio"
  depends_on "portmidi"
  depends_on "python@3.15"

  uses_from_macos "flex" => :build
  uses_from_macos "curl"

  on_linux do
    depends_on "alsa-lib"
    depends_on "libx11"
    depends_on "pipewire"
    depends_on "pulseaudio"
    depends_on "zlib-ng-compat"
  end

  conflicts_with "libextractor", because: "both install `extract` binaries"

  def install
    rpaths = [rpath]
    rpaths << rpath(target: frameworks) if OS.mac?

    system "cmake", "-S", ".", "-B", "build",
                    "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
                    "-DBISON_EXECUTABLE=#{formula_opt_bin("bison")}/bison",
                    "-DBUILD_TESTS=OFF",
                    "-DCS_FRAMEWORK_DEST=#{frameworks}",
                    "-DINSTALL_PYTHON_INTERFACE=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    if OS.mac?
      include.install_symlink frameworks/"CsoundLib64.framework/Headers" => "csound"
    else
      # On Linux, csound depends on binutils, but both formulae install `srconv` binaries
      (bin/"srconv").unlink
    end
  end

  def caveats
    on_linux do
      <<~EOS
        srconv is not installed because it conflicts with binutils. To run srconv:
          csound --utility=srconv
      EOS
    end
  end

  test do
    (testpath/"test.orc").write <<~ORC
      0dbfs = 1
      instr 1
          out oscils(0.5 * 0dbfs, 440, 0)
      endin
    ORC

    (testpath/"test.sco").write <<~SCO
      i 1 0 1
      e
    SCO

    if OS.mac?
      ENV["OPCODE6DIR64"] = frameworks/"CsoundLib64.framework/Resources/Opcodes64"
      ENV["SADIR"] = frameworks/"CsoundLib64.framework/Versions/Current/samples"
    else
      ENV["OPCODE6DIR64"] = lib/"csound/plugins64-6.0"
      ENV["SADIR"] = share/"samples"
    end

    system bin/"csound", "test.orc", "test.sco"

    assert_path_exists testpath/"test.#{OS.mac? ? "aif" : "wav"}"
  end
end
