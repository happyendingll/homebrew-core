class Pkcs11Tools < Formula
  desc "Tools to manage objects on PKCS#11 crypotographic tokens"
  homepage "https://github.com/Mastercard/pkcs11-tools"
  url "https://github.com/Mastercard/pkcs11-tools/releases/download/v3.1.0/pkcs11-tools-3.1.0.tar.gz"
  sha256 "ef6d07b5527214cf8dcbed4f017569146f74dd6eb6aa9d5e7297418299b7947d"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "479fc09d5b604fd22bdc87ebb0ec08f4de0da9849e09e77a3b11e845e048a7ca"
  end

  depends_on "pkgconf" => :build
  depends_on "softhsm" => :test
  depends_on "openssl@4"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  # Apply patch to replace direct access with accessor functions
  patch do
    file "Patches/pkcs11-tools/openssl-4.diff"
    type :unofficial
    resolves "https://github.com/Mastercard/pkcs11-tools/issues/103"
  end

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    # configure new softhsm token, generate a token key, and use it
    mkdir testpath/"tokens"
    softhsm_conf = testpath/"softhsm.conf"

    softhsm_conf.write <<~CONF
      directories.tokendir = #{testpath}/tokens
      directories.backend = file
      log.level = INFO
      slots.removable = false
      slots.mechanisms = ALL
      library.reset_on_fork = false
    CONF

    ENV["SOFTHSM2_CONF"] = softhsm_conf
    ENV["PKCS11LIB"] = Formula["softhsm"].lib/"softhsm/libsofthsm2.so"
    ENV["PKCS11TOKENLABEL"] = "test"
    ENV["PKCS11PASSWORD"] = "0000"

    system "softhsm2-util", "--init-token", "--slot", "0", "--label", "test", "--pin", "0000", "--so-pin", "0000"
    system bin/"p11keygen", "-i", "test", "-k", "aes", "-b", "128", "encrypt"
    system bin/"p11kcv", "seck/test"
    system bin/"p11ls"
  end
end
