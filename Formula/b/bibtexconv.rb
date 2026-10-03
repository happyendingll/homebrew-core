class Bibtexconv < Formula
  desc "BibTeX file converter"
  homepage "https://www.nntb.no/~dreibh/bibtexconv/"
  url "https://github.com/dreibh/bibtexconv/archive/refs/tags/bibtexconv-2.2.5.tar.gz"
  sha256 "5d766ec9af261288a71af9d389b407ebdf3a5f5739a166be86e355f2304c7843"
  license "GPL-3.0-or-later"
  head "https://github.com/dreibh/bibtexconv.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "19165b2b00b393da93193d8440ec0c8f1542ef0d5331bf6048b29fc4c887bc1f"
  end

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "openssl@3"

  uses_from_macos "flex" => :build
  uses_from_macos "curl"

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1600
  end

  fails_with :clang do
    build 1600
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
                    "-DCRYPTO_LIBRARY=#{formula_opt_lib("openssl@3")}/#{shared_library("libcrypto")}"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    cp "#{opt_share}/doc/bibtexconv/examples/ExampleReferences.bib", testpath

    system bin/"bibtexconv", testpath/"ExampleReferences.bib",
                             "--export-to-bibtex", "UpdatedReferences.bib",
                             "--check-urls", "--only-check-new-urls",
                             "--non-interactive"
  end
end
