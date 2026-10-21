class Scamper < Formula
  desc "Advanced traceroute and network measurement utility"
  homepage "https://www.caida.org/catalog/software/scamper/"
  url "https://www.caida.org/catalog/software/scamper/code/scamper-cvs-20261019.tar.gz"
  sha256 "83fedacbea65c03d8ef754e0240d4dbfc2efb0cf3f62a5980d0d213c807c7698"
  license "GPL-2.0-only"

  livecheck do
    url "https://www.caida.org/catalog/software/scamper/code/?C=M&O=D"
    regex(/href=.*?scamper(?:-cvs)?[._-]v?(\d{6,8}[a-z]?)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "3a6e04d468ac19b18b7e5f6a7df6a68acba427955e379979b40f9df9d5ee7eed"
  end

  depends_on "pkgconf" => :build
  depends_on "openssl@4"
  depends_on "xz" # for LZMA

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    expected = if OS.mac?
      "dl_bpf_open_dev"
    else
      "scamper_privsep_init"
    end
    assert_match expected, shell_output("#{bin}/scamper -i 127.0.0.1 2>&1", 255)
    assert_match version.to_s, shell_output("#{bin}/scamper -v")
  end
end
