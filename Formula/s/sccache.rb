class Sccache < Formula
  desc "Used as a compiler wrapper and avoids compilation when possible"
  homepage "https://github.com/mozilla/sccache"
  url "https://github.com/mozilla/sccache/archive/refs/tags/v0.20.1.tar.gz"
  sha256 "1568b19b3e9bcf911986670dbf92264100974319ddde0b1ccaeecfa82b953632"
  license "Apache-2.0"
  head "https://github.com/mozilla/sccache.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "b79ca308794d1f2b7d9a18223d72fc96afa23eea2e508f786eadb1c443c96b41"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4" # Uses Secure Transport on macOS
  end

  # `test do` block starts a local sccache server
  allow_network_access! :test

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(features: "all")
  end

  test do
    (testpath/"hello.c").write <<~C
      #include <stdio.h>
      int main() {
        puts("Hello, world!");
        return 0;
      }
    C
    system bin/"sccache", "cc", "hello.c", "-o", "hello-c"
    assert_equal "Hello, world!", shell_output("./hello-c").chomp
  end
end
