class Fwup < Formula
  desc "Configurable embedded Linux firmware update creator and runner"
  homepage "https://github.com/fwup-home/fwup"
  url "https://github.com/fwup-home/fwup/releases/download/v1.17.0/fwup-1.17.0.tar.gz"
  sha256 "d2a7ee4986652650270e5c01c13f854bd17fba27b48cdfff69025be92969e01d"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "8adcfe27b8222a051836bfe55c1d85e337a66085dcc344eb577c89d10fe7cf3f"
    sha256 cellar: :any, arm64_tahoe:       "da9f4b6373e2b51c3d7b88fc01eed5a17dda4fc992952bac085fa52242e6c54c"
    sha256 cellar: :any, arm64_sequoia:     "9209e1ed4485bb5a84477b3a2522fde6b8b48af804ff5844c184dca39227f784"
    sha256 cellar: :any, arm64_linux:       "8e4a5d7b855a1a3610d3ab5cf789a5e6d6da639770c5b1d06b977cc2740861d8"
    sha256 cellar: :any, x86_64_linux:      "70284e632b10f2b8fd6ac103e209999390bfd41c6960b2fd3bbb5f767fa29b60"
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
