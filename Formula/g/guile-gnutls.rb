class GuileGnutls < Formula
  desc "Guile bindings for the GnuTLS library"
  homepage "https://codeberg.org/guile-gnutls/guile-gnutls"
  url "https://codeberg.org/guile-gnutls/guile-gnutls/releases/download/v5.0.3/guile-gnutls-5.0.3.tar.gz"
  sha256 "230ae4f89dffac6d57fff618410611820e1550907aeef6065b121fe6410a7b6b"
  license "LGPL-2.1-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "dde91c8ff3452f8b71f584e5fd13b141588f38ad7db5d863029e79616c72b7b8"
  end

  head do
    url "https://codeberg.org/guile-gnutls/guile-gnutls.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build

    on_system :linux, macos: :ventura_or_newer do
      depends_on "texinfo" => :build
    end
  end

  depends_on "gnutls"
  depends_on "guile"

  on_macos do
    depends_on "bdw-gc"
  end

  def install
    system "./bootstrap" if build.head?
    system "./configure", "--with-guile-site-dir=#{share}/guile/site/3.0",
                          "--with-guile-site-ccache-dir=#{lib}/guile/3.0/site-ccache",
                          "--with-guile-extension-dir=#{lib}/guile/3.0/extensions",
                          "--disable-silent-rules",
                          *std_configure_args.reject { |s| s["--disable-debug"] }
    system "make", "install"
  end

  post_install_steps do
    # Touch gnutls.go to avoid Guile recompilation.
    # See https://github.com/Homebrew/homebrew-core/pull/60307#discussion_r478917491
    touch "{{lib}}/guile/3.0/site-ccache/gnutls.go"
  end

  def caveats
    <<~EOS
      If you are going to use the Guile bindings you will need to add the following
      to your .bashrc or equivalent in order for Guile to find the TLS certificates
      database:
        export GUILE_TLS_CERTIFICATE_DIRECTORY=#{Formula["gnutls"].pkgetc}/
    EOS
  end

  test do
    gnutls = testpath/"gnutls.scm"
    gnutls.write <<~SCHEME
      (use-modules (gnutls))
      (gnutls-version)
    SCHEME

    ENV["GUILE_AUTO_COMPILE"] = "0"
    ENV["GUILE_LOAD_PATH"] = HOMEBREW_PREFIX/"share/guile/site/3.0"
    ENV["GUILE_LOAD_COMPILED_PATH"] = HOMEBREW_PREFIX/"lib/guile/3.0/site-ccache"
    ENV["GUILE_SYSTEM_EXTENSIONS_PATH"] = HOMEBREW_PREFIX/"lib/guile/3.0/extensions"

    system "guile", gnutls
  end
end
