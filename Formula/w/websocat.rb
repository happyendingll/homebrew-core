class Websocat < Formula
  desc "Command-line client for WebSockets"
  homepage "https://github.com/vi/websocat"
  url "https://github.com/vi/websocat/archive/refs/tags/v1.14.2.tar.gz"
  sha256 "cb49afdb6c108c5be9ae2e78d72f4c31cd2e464d4e3a9faa1e9f958b61e53e3d"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "3fcb2848c4596c5a69b5ff2de4b53f1755a64147c9bb39aa6a3d02b93576a917"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  # Match Cargo.lock's package version to Cargo.toml for locked builds.
  patch do
    url "https://github.com/vi/websocat/commit/dbeaa84544e054014a23d199de5c490c8989248a.patch?full_index=1"
    sha256 "c7473d519369f89978dfcfe7c8eed285e085b87a955cd3394737528c66a2e50a"
    type :unofficial
    resolves "https://github.com/vi/websocat/pull/319"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args(features: "ssl")
  end

  test do
    system bin/"websocat", "-t", "literal:qwe", "assert:qwe"
  end
end
