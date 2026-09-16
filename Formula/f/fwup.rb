class Fwup < Formula
  desc "Configurable embedded Linux firmware update creator and runner"
  homepage "https://github.com/fwup-home/fwup"
  url "https://github.com/fwup-home/fwup/releases/download/v1.17.0/fwup-1.17.0.tar.gz"
  sha256 "d2a7ee4986652650270e5c01c13f854bd17fba27b48cdfff69025be92969e01d"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "32f058bf7612fea15acb247d91ef1ef8b40df45783460de3b60119046ca5342b"
  end

  depends_on "pkgconf" => :build
  depends_on "confuse"
  depends_on "libarchive"

  # Avoid `CFRelease(NULL)` crash at exit when DiskArbitration is unreachable (e.g. in a sandbox)
  patch do
    url "https://github.com/fwup-home/fwup/commit/f07d3a65541f26eb72a8f4b7950f6d2eae47c8c4.patch?full_index=1"
    sha256 "9ec7ca0990889dc4721477919e4783df5ab078b1ca5e54b66d902ac1ecc12e23"
    type :unofficial
    resolves "https://github.com/fwup-home/fwup/pull/310"
  end

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"fwup", "-g"
    assert_path_exists testpath/"fwup-key.priv", "Failed to create fwup-key.priv!"
    assert_path_exists testpath/"fwup-key.pub", "Failed to create fwup-key.pub!"
  end
end
