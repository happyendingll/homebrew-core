class Gitnr < Formula
  desc "Create `.gitignore` using templates from TopTal, GitHub or your own collection"
  homepage "https://github.com/reemus-dev/gitnr"
  url "https://github.com/reemus-dev/gitnr/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "06b1ab4a5ff56c815162485a9d90aae1d72b0c042f9be15b7db20c210a80f378"
  license "MIT"
  head "https://github.com/reemus-dev/gitnr.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "6b18fb022b212c42577c960165ee330ff4947d01ede3866ac2d1c263412eef32"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  # Update openssl and openssl-sys to same versions as dependabot PR
  # (https://github.com/reemus-dev/gitnr/pull/22) to support OpenSSL 4
  patch :DATA

  # `test do` block downloads a GitHub template.
  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4")
    system "cargo", "install", *std_cargo_args
  end

  test do
    system bin/"gitnr create gh:Rust"

    system bin/"gitnr create gh:Rust > #{testpath}/.gitignore.rust"
    assert_path_exists testpath/".gitignore.rust"
  end
end

__END__
diff --git a/Cargo.lock b/Cargo.lock
index be3be43..f213b22 100644
--- a/Cargo.lock
+++ b/Cargo.lock
@@ -954,15 +954,14 @@ checksum = "384b8ab6d37215f3c5301a95a4accb5d64aa607f1fcb26a11b5303878451b4fe"
 
 [[package]]
 name = "openssl"
-version = "0.10.76"
+version = "0.10.80"
 source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "951c002c75e16ea2c65b8c7e4d3d51d5530d8dfa7d060b4776828c88cfb18ecf"
+checksum = "a45fa2aa886c42762255da344f0a0d313e254066c46aad76f300c3d3da62d967"
 dependencies = [
  "bitflags",
  "cfg-if",
  "foreign-types",
  "libc",
- "once_cell",
  "openssl-macros",
  "openssl-sys",
 ]
@@ -986,9 +985,9 @@ checksum = "7c87def4c32ab89d880effc9e097653c8da5d6ef28e6b539d313baaacfbafcbe"
 
 [[package]]
 name = "openssl-sys"
-version = "0.9.112"
+version = "0.9.116"
 source = "registry+https://github.com/rust-lang/crates.io-index"
-checksum = "57d55af3b3e226502be1526dfdba67ab0e9c96fc293004e79576b2b9edb0dbdb"
+checksum = "f28a22dc7140cda5f096e5e7724a6962ca81a7f8bfd2979f9b18c11af56318c4"
 dependencies = [
  "cc",
  "libc",
