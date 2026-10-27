class Roswell < Formula
  desc "Lisp installer and launcher for major environments"
  homepage "https://github.com/roswell/roswell"
  url "https://github.com/roswell/roswell/archive/refs/tags/v26.10.119.tar.gz"
  sha256 "211c99ab4e077c5ba3d3fc43e095c31a2f0706bdde26664b2981095d01296a39"
  license "MIT"
  head "https://github.com/roswell/roswell.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 sequoia: "3605b4b78d2b68049cb8917ea296868337a611a8d8e1c3c1705053edc6f22ae1"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  uses_from_macos "curl"

  def install
    system "./bootstrap"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    ENV["ROSWELL_HOME"] = testpath
    system bin/"ros", "init"
    assert_path_exists testpath/"config"
  end
end
