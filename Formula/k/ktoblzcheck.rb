class Ktoblzcheck < Formula
  desc "Library for German banks"
  homepage "https://ktoblzcheck.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/ktoblzcheck/ktoblzcheck-1.59.tar.gz"
  sha256 "3cd33880d2425e8fa3be9918c85485514f53e04b0b986bcf7bd003fc53071fa7"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
    regex(%r{url=.*?/ktoblzcheck[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "6823f265f39dd077cbcf6c986cb1bf226ba6f853b876b79495698c7f25759ed5"
  end

  depends_on "cmake" => :build
  depends_on "python@3.15"
  depends_on "sqlite"

  uses_from_macos "curl"

  pypi_packages package_name:   "",
                extra_packages: "openpyxl"

  resource "et-xmlfile" do
    url "https://files.pythonhosted.org/packages/d3/38/af70d7ab1ae9d4da450eeec1fa3918940a5fafb9055e934af8d6eb0c2313/et_xmlfile-2.0.0.tar.gz"
    sha256 "dab3f4764309081ce75662649be815c4c9081e88f0837825f90fd28317d4da54"
  end

  resource "openpyxl" do
    url "https://files.pythonhosted.org/packages/3d/f9/88d94a75de065ea32619465d2f77b29a0469500e99012523b91cc4141cd1/openpyxl-3.1.5.tar.gz"
    sha256 "cf0e3cf56142039133628b5acffe8ef0c12bc902d2aadd3e0fe5878dc08d1050"
  end

  # Bankdata resource
  resource "ktoblzcheck-data" do
    url "https://downloads.sourceforge.net/project/ktoblzcheck/ktoblzcheck-data-20250515.tar.gz"
    sha256 "307479cd3c487ba6d6c4f5966634a6023c1f29d4386b93a5e96cea7541bebe4c"

    livecheck do
      url :url
      regex(/url=.*?ktoblzcheck-data[._-]v?(\d+(?:\.\d+)*)\.t/i)
    end
  end

  def install
    ENV.append_path "PYTHONPATH", buildpath/Language::Python.site_packages(python3)
    resources.each do |r|
      next if r.name == "ktoblzcheck-data"

      r.stage do
        system python3, "-m", "pip", "install", *std_pip_args(prefix: buildpath, build_isolation: true), "."
      end
    end

    resource("ktoblzcheck-data").stage do
      system "cmake", "-S", ".", "-B", "data", *std_cmake_args
      system "cmake", "--build", "data"
      system "cmake", "--install", "data"

      # Move built bankdata to the path of bankdata for `ktoblzcheck`
      (buildpath/"src/bankdata").install "data"
    end

    # Work around to help Python bindings find shared library on macOS.
    # OSError: dlopen(ktoblzcheck, 0x0006): tried: 'ktoblzcheck' (no such file), ...
    # OSError: dlopen(libktoblzcheck.so.1, 0x0006): tried: 'libktoblzcheck.so.1' (no such file), ...
    inreplace "src/python/ktoblzcheck.py", /'libktoblzcheck\.so\.(\d+)'/, "'libktoblzcheck.\\1.dylib'" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, "-DCMAKE_INSTALL_RPATH=#{opt_lib}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "Ok", shell_output("#{bin}/ktoblzcheck --outformat=oneline 10000000 123456789")
    assert_match "unknown", shell_output("#{bin}/ktoblzcheck --outformat=oneline 12345678 100000000", 3)
    system python3, "-c", "import ktoblzcheck"
  end
end
