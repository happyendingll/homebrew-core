class LinkGrammar < Formula
  desc "Carnegie Mellon University's link grammar parser"
  homepage "https://github.com/opencog/link-grammar"
  url "https://github.com/opencog/link-grammar/archive/refs/tags/link-grammar-5.13.0.tar.gz"
  sha256 "a545b7efb7aceab2d8ad301466f199778a3da712928999ed8d66deb32ca3184f"
  license "LGPL-2.1-or-later"
  head "https://github.com/opencog/link-grammar.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "eb9d0bd046cfd54ed644d2df20a0cbf7dc53e883c19bd7c633a705875f454a24"
  end

  depends_on "ant" => :build
  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.14" => :build
  depends_on "swig" => :build

  uses_from_macos "flex" => :build
  uses_from_macos "libedit"
  uses_from_macos "sqlite"

  # Fix build when autoconf adds `-std=gnu23` to `CC`
  patch do
    url "https://github.com/opencog/link-grammar/commit/b296c8fa844a66c1320b4d04713e615db9d011f0.patch?full_index=1"
    sha256 "072b663ed547792761786530cf367b49ed526e2a722120b0f8565e1f36a21b36"
    type :backport
    resolves "https://github.com/opencog/link-grammar/pull/1540"
  end

  # Fix build with SWIG 4.5, which dropped the Python 2 `PyInt_*` compatibility macros
  patch do
    url "https://github.com/opencog/link-grammar/commit/5611221d83fc6571418e86374bbfa5daf5e5428a.patch?full_index=1"
    sha256 "f72c7482d73fd21e6b766a147d15ac7f6186a99b632093aa4e6161620e3ac3ff"
    type :unofficial
    resolves "https://github.com/opencog/link-grammar/pull/1543"
  end

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
