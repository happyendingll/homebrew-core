class GitCinnabar < Formula
  desc "Git remote helper to interact with mercurial repositories"
  homepage "https://github.com/glandium/git-cinnabar"
  url "https://static.crates.io/crates/git-cinnabar/git-cinnabar-0.7.5.crate"
  sha256 "b7f51bf94f7795deb25b862c72a57f83c48f84d12e52c20e5f99f6c70397a516"
  license all_of: ["MPL-2.0", "GPL-2.0-only"]
  head "https://github.com/glandium/git-cinnabar.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "12653b4b1412117a8bd0237d41d726b372db1bc3b5a10096ab4d89e7a0a5bb9a"
  end

  depends_on "rust" => :build
  depends_on "mercurial"

  uses_from_macos "bzip2"
  uses_from_macos "curl"

  on_linux do
    depends_on "pkgconf" => :build # for curl-sys, not used on macOS
    depends_on "zlib-ng-compat"
  end

  conflicts_with "git-remote-hg", because: "both install `git-remote-hg` binaries"

  def install
    system "cargo", "install", *std_cargo_args
    bin.install_symlink bin/"git-cinnabar" => "git-remote-hg"
  end

  test do
    system "git", "-c", "cinnabar.check=traceback", "clone", "hg::https://www.mercurial-scm.org/repo/hello"
    assert_path_exists testpath/"hello/hello.c", "hello.c not found in cloned repo"
  end
end
