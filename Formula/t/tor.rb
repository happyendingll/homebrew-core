class Tor < Formula
  desc "Anonymizing overlay network for TCP"
  homepage "https://www.torproject.org/"
  url "https://dist.torproject.org/tor-0.4.9.13.tar.gz"
  mirror "https://fossies.org/linux/misc/tor-0.4.9.13.tar.gz"
  sha256 "5e748d3272cdf44a7d7741173f371c8def3d96eecb77e93c89c50663ce9cc792"
  # Complete list of licenses:
  # https://gitweb.torproject.org/tor.git/plain/LICENSE
  license all_of: [
    "BSD-2-Clause",
    "BSD-3-Clause",
    "MIT",
    "NCSA",
  ]
  compatibility_version 1

  livecheck do
    url "https://dist.torproject.org/"
    regex(/href=.*?tor[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 sequoia: "53241a4824f9c24fb23d71634486a5ca056a57bcf8231dc771447827e51c3731"
  end

  depends_on "pkgconf" => :build
  depends_on "libevent"
  depends_on "libscrypt"
  depends_on "openssl@3"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      --disable-silent-rules
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --with-openssl-dir=#{formula_opt_prefix("openssl@3")}
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  service do
    run opt_bin/"tor"
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/tor.log"
    error_log_path var/"log/tor.log"
  end

  test do
    pipe_output("#{bin}/tor-gencert --create-identity-key --passphrase-fd 0")
    assert_path_exists testpath/"authority_certificate"
    assert_path_exists testpath/"authority_identity_key"
    assert_path_exists testpath/"authority_signing_key"
  end
end
