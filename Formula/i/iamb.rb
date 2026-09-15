class Iamb < Formula
  desc "Matrix client for Vim addicts"
  homepage "https://iamb.chat"
  url "https://github.com/ulyssa/iamb/archive/refs/tags/v0.0.11.tar.gz"
  sha256 "a5cf4f248e0893b5657c5ad1234207c09968018c5462d4063c096f0db459dd7c"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "005edda6164cb067a8848c81b098d3e2c537e4478489072899c2d09c7cda907a"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "sqlite", since: :ventura # requires sqlite3_error_offset

  on_linux do
    depends_on "openssl@3"
  end

  # Rust 1.94+ overflows the default recursion limit on matrix-sdk futures
  patch do
    url "https://github.com/ulyssa/iamb/commit/d69bc64cb9f6ddd150d5a6f1e08119f4cc74740e.patch?full_index=1"
    sha256 "c7f804a296abe18828d26884098a6755bd633705f4703648b0154bca74c29f4a"
    type :backport
    resolves "https://github.com/ulyssa/iamb/pull/599"
  end

  def install
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"
    ENV["VERGEN_GIT_SHA"] = tap.user
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "Please create a configuration file", shell_output(bin/"iamb", 2)
  end
end
