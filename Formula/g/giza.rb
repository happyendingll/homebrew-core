class Giza < Formula
  desc "Scientific plotting library for C/Fortran built on cairo"
  homepage "https://danieljprice.github.io/giza/"
  url "https://github.com/danieljprice/giza/releases/download/v2.0.1/giza-v2.0.1.tar.gz"
  sha256 "a62b0fc68712ed12ede18a7adec0d49a7784f266a11d71cb16ad4890c396986f"
  license "LGPL-3.0-only"
  head "https://github.com/danieljprice/giza.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "cbffc242014b4f3c452733ad49c616547969aa9de9fb3285ca21c47f3b70fb81"
  end

  depends_on "pkgconf" => :build

  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc" # for gfortran
  depends_on "libx11"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"

    # Install test files to use during `brew test`
    rm(Dir["test/**/Makefile*"])
    prefix.install "test"
  end

  test do
    cp_r prefix/"test/C/.", testpath

    flags = %W[
      -I#{include}
      -I#{formula_opt_include("cairo")}/cairo
      -L#{lib}
      -L#{formula_opt_lib("libx11")}
      -L#{formula_opt_lib("cairo")}
      -lX11
      -lcairo
      -lgiza
    ]

    %w[
      test-XOpenDisplay.c
      test-cairo-xw.c
      test-giza-xw.c
      test-rectangle.c
      test-window.c
    ].each do |file|
      system ENV.cc, file, *flags
    end
  end
end
