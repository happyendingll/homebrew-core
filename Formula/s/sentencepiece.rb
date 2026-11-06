class Sentencepiece < Formula
  desc "Unsupervised text tokenizer and detokenizer"
  homepage "https://github.com/google/sentencepiece"
  url "https://github.com/google/sentencepiece/archive/refs/tags/v0.2.3.tar.gz"
  sha256 "aeabf9b2ae1a77cda6e721ab1fb9f6e44b8ba4ddb8d7343dc5b02aec70fab324"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/google/sentencepiece.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "6b526fc44f64bbb6889a21b84e0baf4f00c526f841b99fd495ca9a883eb3fd8b"
  end

  depends_on "cmake" => :build
  depends_on "flatbuffers" => :build
  depends_on "pybind11" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.15" => [:build, :test]
  depends_on "abseil"
  depends_on "protobuf"

  deny_network_access!

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DSPM_PROTOBUF_PROVIDER=package",
                    "-DSPM_ABSL_PROVIDER=package",
                    "-DSPM_ENABLE_TCMALLOC=OFF",
                    # Use brewed `flatbuffers` instead of FetchContent, which needs brew's provider bypassed
                    "-DHOMEBREW_ALLOW_FETCHCONTENT=ON",
                    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON",
                    "-DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS",
                    "-DSPM_FLATC_EXECUTABLE=#{formula_opt_bin("flatbuffers")}/flatc",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Workaround to link python module to shared sentencepiece
    inreplace "python/setup.py",
              "['libsentencepiece.a', 'libsentencepiece_train.a']",
              "['#{shared_library("libsentencepiece")}', '#{shared_library("libsentencepiece_train")}']"
    sentencepiece_site_packages = prefix/Language::Python.site_packages(python3)/"sentencepiece"
    ENV.append "LDFLAGS", "-Wl,-rpath,#{rpath(source: sentencepiece_site_packages)}" if OS.mac?

    system python3, "-m", "pip", "install", *std_pip_args, "./python"

    pkgshare.install "data"
  end

  test do
    cp (pkgshare/"data/botchan.txt"), testpath
    system bin/"spm_train", "--input=botchan.txt", "--model_prefix=m", "--vocab_size=1000"

    (testpath/"test.py").write <<~PYTHON
      import sentencepiece as spm
      sp = spm.SentencePieceProcessor(model_file='m.model')
      pieces = sp.encode('Hello world', return_type=str)
      print(pieces)
      print(sp.decode(pieces))
    PYTHON
    assert_equal <<~EOS, shell_output("#{python3} test.py")
      ['▁He', 'll', 'o', '▁world']
      Hello world
    EOS
  end
end
