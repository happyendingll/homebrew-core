class Pillow < Formula
  desc "Friendly PIL fork (Python Imaging Library)"
  homepage "https://python-pillow.org/"
  url "https://files.pythonhosted.org/packages/ce/a4/9cc30690a394a8305e8be4c9036aa16d0dfddadd09079860b582f562496d/pillow-13.0.0.tar.gz"
  sha256 "cdcd1ba258178f7356d74170c9a81ba4eab6a5d55748bc402a5a2a6fe6be3510"
  license "MIT-CMU"
  compatibility_version 1
  head "https://github.com/python-pillow/Pillow.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "59a980d0598782a1e9f6dd6c96154ea6e4a481c8a8aafe2ce47f7df6509f36e6"
  end

  depends_on "pkgconf" => :build
  depends_on "pybind11" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.14" => [:build, :test]
  depends_on "python@3.15" => [:build, :test]
  depends_on "freetype"
  depends_on "jpeg-turbo"
  depends_on "libavif"
  depends_on "libimagequant"
  depends_on "libraqm"
  depends_on "libtiff"
  depends_on "libxcb"
  depends_on "little-cms2"
  depends_on "openjpeg"
  depends_on "webp"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # Test webp support
  resource "test-webp", :test do
    url "https://raw.githubusercontent.com/python-pillow/Pillow/refs/heads/main/Tests/images/flower.webp"
    sha256 "af5bf1a0e420467c09d221fbfbb739646956c17f2b67f8280eacfacf87059a37"
  end

  # Test avif support
  resource "test-avif", :test do
    url "https://raw.githubusercontent.com/python-pillow/Pillow/refs/heads/main/Tests/images/avif/exif.avif"
    sha256 "438dc63eb5aa722f4b23a93ac48cd0c19b7a575865c89e666c86b7ac363cff04"
  end

  deny_network_access!

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    ENV["MAX_CONCURRENCY"] = ENV.make_jobs.to_s
    deps.each do |dep|
      next if dep.build? || dep.test?

      ENV.prepend "CPPFLAGS", "-I#{dep.to_formula.opt_include}"
      ENV.prepend "LDFLAGS", "-L#{dep.to_formula.opt_lib}"
    end

    pythons.each do |python|
      system python, "-m", "pip", "install", *std_pip_args,
                     "-C", "debug=true", # Useful in case of build failures.
                     "-C", "tiff=enable",
                     "-C", "freetype=enable",
                     "-C", "lcms=enable",
                     "-C", "webp=enable",
                     "-C", "xcb=enable",
                     "-C", "avif=enable",
                     "."
    end
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      from PIL import Image
      im = Image.open("#{test_fixtures("test.jpg")}")
      print(im.format, im.size, im.mode)
    PYTHON

    pythons.each do |python|
      assert_equal "JPEG (1, 1) RGB", shell_output("#{python} test.py").chomp
    end

    testpath.install resource("test-webp")
    test_webp = testpath/"flower.webp"
    (testpath/"test_webp.py").write <<~PYTHON
      from PIL import Image
      im = Image.open("#{test_webp}")
      print(im.format, im.size, im.mode)
    PYTHON

    pythons.each do |python|
      assert_equal "WEBP (480, 360) RGB", shell_output("#{python} test_webp.py").chomp
    end

    testpath.install resource("test-avif")
    test_avif = testpath/"exif.avif"
    (testpath/"test_avif.py").write <<~PYTHON
      from PIL import Image
      im = Image.open("#{test_avif}")
      print(im.format, im.size, im.mode)
    PYTHON

    pythons.each do |python|
      assert_equal "AVIF (512, 512) RGB", shell_output("#{python} test_avif.py").chomp
    end
  end
end
