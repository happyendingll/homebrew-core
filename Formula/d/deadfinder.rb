class Deadfinder < Formula
  desc "Finds broken links"
  homepage "https://deadfinder.hahwul.com"
  url "https://github.com/hahwul/deadfinder/archive/refs/tags/2.1.0.tar.gz"
  sha256 "ae2364f33c1b94f9d2183162b6dd42ae33a68dbda970a1e67c9080ee1681c7d9"
  license "MIT"
  head "https://github.com/hahwul/deadfinder.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "9b1c8f9780ac052d484a5ce9f271fc8b3043e7b3f155dc1408fd4cb792eb8317"
  end

  depends_on "crystal" => :build
  depends_on "lexbor" => :build
  depends_on "pkgconf" => :build
  depends_on "bdw-gc"
  depends_on "libevent"
  depends_on "libyaml"
  depends_on "openssl@3"
  depends_on "pcre2"

  uses_from_macos "libxml2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  allow_network_access! :test

  def fetch
    system "shards", "install", "--production", "--skip-postinstall"
  end

  def install
    ENV["CRYSTAL_LIBRARY_PATH"] = formula_opt_lib("openssl@3")
    ENV.prepend_path "PKG_CONFIG_PATH", formula_opt_lib("openssl@3")/"pkgconfig"

    # Use our lexbor as long as compatible with https://github.com/kostya/lexbor
    (buildpath/"lib/lexbor/src/ext/lexbor-c/build").install_symlink formula_opt_lib("lexbor")/"liblexbor_static.a"

    system "shards", "build", *std_shards_args
    bin.install "bin/deadfinder"

    generate_completions_from_executable(bin/"deadfinder", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/deadfinder version")

    assert_match "Task completed", shell_output("#{bin}/deadfinder url https://brew.sh")
  end
end
