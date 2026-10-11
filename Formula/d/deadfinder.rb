class Deadfinder < Formula
  desc "Finds broken links"
  homepage "https://deadfinder.hahwul.com"
  url "https://github.com/hahwul/deadfinder/archive/refs/tags/2.1.0.tar.gz"
  sha256 "ae2364f33c1b94f9d2183162b6dd42ae33a68dbda970a1e67c9080ee1681c7d9"
  license "MIT"
  revision 1
  head "https://github.com/hahwul/deadfinder.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-2"
    sha256 cellar: :any, sequoia: "d6fac1b901938b8887b0227fb575ac86cef460e5725d25b98ba076a7ef8dae4f"
  end

  depends_on "crystal" => :build
  depends_on "lexbor" => :build
  depends_on "pkgconf" => :build
  depends_on "bdw-gc"
  depends_on "libevent"
  depends_on "libyaml"
  depends_on "openssl@4"
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
