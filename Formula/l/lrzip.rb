class Lrzip < Formula
  desc "Compression program with a very high compression ratio"
  homepage "https://github.com/ckolivas/lrzip"
  url "https://github.com/ckolivas/lrzip/releases/download/v0.7.3/lrzip-0.7.3.tar.xz"
  sha256 "6928862de7c4bbb3cfbcd12fae9fd0a7d230d5bbf27486e52c4de60717ebfdbb"
  license "GPL-2.0-or-later"
  version_scheme 1
  head "https://github.com/ckolivas/lrzip.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "a2d2787d85da4eafcd07eb231de5f1673de8388846e4452afde66d2c049b52a5"
  end

  depends_on "lz4"
  depends_on "lzo"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  conflicts_with "lrzsz", because: "both install `lrz` binaries"

  def install
    system "./configure", *std_configure_args
    system "make", "SHELL=bash"
    system "make", "install"
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.lrz
    system bin/"lrzip", "-o", "#{path}.lrz", path
    path.unlink

    # decompress: data.txt.lrz -> data.txt
    system bin/"lrzip", "-d", "#{path}.lrz"
    assert_equal original_contents, path.read
  end
end
