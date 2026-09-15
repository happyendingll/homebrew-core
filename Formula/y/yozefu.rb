class Yozefu < Formula
  desc "TUI for exploring data in a Kafka cluster"
  homepage "https://maif.github.io/yozefu/"
  url "https://github.com/MAIF/yozefu/archive/refs/tags/v0.0.32.tar.gz"
  sha256 "ff2b0d57fe8c26a7bf5c957c341e2db3a0c98f1f271085bb8bff2bfb934fcf2f"
  license "Apache-2.0"
  head "https://github.com/MAIF/yozefu.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "7062cbd09a3b7b887efd9f43dcec566ac343e0479255143c10c627e65fba8aa6"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@4"

  uses_from_macos "llvm" => :build # for libclang

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4")

    system "cargo", "install", *std_cargo_args(path: "crates/bin")
  end

  test do
    require "utils/linkage"

    assert_match version.to_s, shell_output("#{bin}/yozf --version")

    output = shell_output("#{bin}/yozf config get a 2>&1", 1)
    assert_match "Error: There is no 'a' property in the config file", output

    [
      formula_opt_lib("openssl@4")/shared_library("libssl"),
      formula_opt_lib("openssl@4")/shared_library("libcrypto"),
    ].each do |library|
      assert Utils.binary_linked_to_library?(bin/"yozf", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
