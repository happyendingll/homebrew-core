class CargoCrev < Formula
  desc "Code review system for the cargo package manager"
  homepage "https://github.com/crev-dev/cargo-crev"
  url "https://github.com/crev-dev/cargo-crev/archive/refs/tags/v0.27.1.tar.gz"
  sha256 "785ed01f3352331ac4f6ecd63da5ab896a4d251678ad75b6bcf1545858a4cc82"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "2d5c6d27dc4c1fac0af0c75ba4f295d182966d299520cb6f831838067a58e35b"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test
  depends_on "openssl@4"

  # https://github.com/crev-dev/cargo-crev/pull/880
  on_linux do
    depends_on "zlib-ng-compat"
  end

  patch do
    url "https://github.com/crev-dev/cargo-crev/commit/974a24a1d7f77794bcc9029b5f059ba535e13340.patch?full_index=1"
    sha256 "54373e086a0070f24e3f03161a4ed1c9c78422f3471b9394cb2b57749590c4d3"
    type :unofficial
  end

  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "cargo-crev")
  end

  test do
    require "utils/linkage"

    # Show that we can use a different toolchain than the one provided by the `rust` formula.
    # https://github.com/Homebrew/homebrew-core/pull/134074#pullrequestreview-1484979359
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "beta"

    system "cargo", "crev", "config", "dir"

    [
      formula_opt_lib("openssl@4")/shared_library("libssl"),
      formula_opt_lib("openssl@4")/shared_library("libcrypto"),
    ].each do |library|
      assert Utils.binary_linked_to_library?(bin/"cargo-crev", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
