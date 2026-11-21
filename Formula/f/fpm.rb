class Fpm < Formula
  desc "Package manager and build system for Fortran"
  homepage "https://fpm.fortran-lang.org"
  url "https://github.com/fortran-lang/fpm/releases/download/v0.14.0/fpm-0.14.0.F90"
  sha256 "a620bbb6dcb6f704badb63dd0d3b944fd437b3a8e2e4e3acd54ac23ea06bd81b"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "3f60a56415829594ee90aacc0c4b129ad8080ef7c059072df7f4d65ccee4cfbf"
  end

  depends_on "gcc" # for gfortran

  def install
    mkdir_p "build/bootstrap"
    system "gfortran", "-J", "build/bootstrap", "-o", "build/bootstrap/fpm", "fpm-#{version}.F90"
    bin.install "build/bootstrap/fpm"
  end

  test do
    system bin/"fpm", "new", "hello"
    assert_path_exists testpath/"hello"
  end
end
