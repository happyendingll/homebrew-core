class Wxmaxima < Formula
  desc "Cross platform GUI for Maxima"
  homepage "https://wxmaxima-developers.github.io/wxmaxima/"
  url "https://github.com/wxMaxima-developers/wxmaxima/archive/refs/tags/Version-26.09.0.tar.gz"
  sha256 "c490e30383e77e17de2005276429606ff4c5b43ae268aa889cfc3d4fb148a9e9"
  license "GPL-2.0-or-later"
  head "https://github.com/wxMaxima-developers/wxmaxima.git", branch: "main"

  livecheck do
    url :stable
    regex(/^Version[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "9de938cdf8a6902b6736d69ac7ba12eeaad8a8069a8b81cc5d0863b6b25e69e6"
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "ninja" => :build

  depends_on "fribidi"
  depends_on "maxima"
  depends_on "wxwidgets"

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1300
  end

  on_linux do
    depends_on "xorg-server" => :test
  end

  fails_with :clang do
    build 1300
    cause <<~EOS
      .../src/MathParser.cpp:1239:10: error: no viable conversion from returned value
      of type 'CellListBuilder<>' to function return type 'std::unique_ptr<Cell>'
        return tree;
               ^~~~
    EOS
  end

  def install
    # Disable CMake fixup_bundle to prevent copying dylibs
    inreplace "src/CMakeLists.txt", "fixup_bundle(", "# \\0"

    # https://github.com/wxMaxima-developers/wxmaxima/blob/main/Compiling.md#wxwidgets-isnt-found
    args = OS.mac? ? [] : ["-DWXM_DISABLE_WEBVIEW=ON"]

    system "cmake", "-S", ".", "-B", "build-wxm", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build-wxm"
    system "cmake", "--install", "build-wxm"
    bash_completion.install "data/wxmaxima"

    return unless OS.mac?

    bin.write_exec_script prefix/"wxmaxima.app/Contents/MacOS/wxmaxima"
  end

  def caveats
    <<~EOS
      When you start wxMaxima the first time, set the path to Maxima
      (e.g. #{HOMEBREW_PREFIX}/bin/maxima) in the Preferences.

      Enable gnuplot functionality by setting the following variables
      in ~/.maxima/maxima-init.mac:
        gnuplot_command:"#{HOMEBREW_PREFIX}/bin/gnuplot"$
        draw_command:"#{HOMEBREW_PREFIX}/bin/gnuplot"$
    EOS
  end

  test do
    # Cannot run any useful test within macOS sandbox
    wxmaxima = bin/"wxmaxima"
    assert_path_exists wxmaxima
    return if OS.mac?

    IO.pipe do |read_io, write_io|
      pid = spawn(formula_opt_bin("xorg-server")/"Xvfb", "-displayfd", write_io.fileno.to_s, write_io => write_io)
      write_io.close
      ENV["DISPLAY"] = ":#{read_io.read.strip}"
      assert_match "wxMaxima #{version}", shell_output("#{wxmaxima} --version 2>&1").chomp
      assert_match "extra Maxima arguments", shell_output("#{wxmaxima} --help 2>&1", 1)
    ensure
      if pid
        Process.kill "TERM", pid
        Process.wait pid
      end
    end
  end
end
