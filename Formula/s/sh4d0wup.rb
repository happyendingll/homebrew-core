class Sh4d0wup < Formula
  desc "Signing-key abuse and update exploitation framework"
  homepage "https://github.com/kpcyrd/sh4d0wup"
  url "https://github.com/kpcyrd/sh4d0wup/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "92c88eed86e7f6453807db2e5b154859a5952d3ff6be8a2a685879a838f3438f"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "8bfad988c6c48839e23a4517e60c275ef2dff3870224c4769f47d119277ddec2"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "pgpdump" => :test

  depends_on "openssl@4"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "llvm" => :build
  uses_from_macos "pcsc-lite"

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4")

    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"sh4d0wup", "completions")
  end

  test do
    require "utils/linkage"

    output = shell_output("#{bin}/sh4d0wup keygen tls example.com | openssl x509 -text -noout")
    assert_match("DNS:example.com", output)

    output = shell_output("#{bin}/sh4d0wup keygen pgp | pgpdump")
    assert_match("New: Public Key Packet", output)

    output = shell_output("#{bin}/sh4d0wup keygen ssh --type=ed25519 --bits=256 | ssh-keygen -lf -")
    assert_match("no comment (ED25519)", output)

    output = shell_output("#{bin}/sh4d0wup keygen openssl --secp256k1 | openssl ec -text -noout")
    assert_match("ASN1 OID: secp256k1", output)

    [
      formula_opt_lib("openssl@4")/shared_library("libssl"),
      formula_opt_lib("openssl@4")/shared_library("libcrypto"),
    ].each do |library|
      assert Utils.binary_linked_to_library?(bin/"sh4d0wup", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
