class LinkGrammar < Formula
  desc "Carnegie Mellon University's link grammar parser"
  homepage "https://github.com/opencog/link-grammar"
  url "https://github.com/opencog/link-grammar/archive/refs/tags/link-grammar-5.13.2.tar.gz"
  sha256 "6305b3c0d59dfbf0d0bafc715995beebf0e383a968f4cc7a665f313e69b4c059"
  license "LGPL-2.1-or-later"
  head "https://github.com/opencog/link-grammar.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "942b8adb1d5b236e5c17ac3c24a297889ac9176424c71d1a5bd5d13503531da5"
  end

  depends_on "ant" => :build
  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.15" => :build
  depends_on "swig" => :build

  uses_from_macos "flex" => :build
  uses_from_macos "libedit"
  uses_from_macos "sqlite"

  def install
    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1403

    ENV["PYTHON_LIBS"] = "-undefined dynamic_lookup"
    inreplace "bindings/python/Makefile.am", "$(PYTHON_LDFLAGS) -module -no-undefined",
                                             "$(PYTHON_LDFLAGS) -module"
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", "--with-regexlib=c", *std_configure_args

    # Work around error due to install using detected path inside Python formula.
    # install: .../site-packages/linkgrammar.pth: Operation not permitted
    site_packages = prefix/Language::Python.site_packages(python3)
    system "make", "install", "pythondir=#{site_packages}",
                              "pyexecdir=#{site_packages}"
  end

  test do
    system bin/"link-parser", "--version"
  end
end
