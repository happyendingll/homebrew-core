class GitAnnex < Formula
  desc "Manage files with git without checking in file contents"
  homepage "https://git-annex.branchable.com/"
  url "https://hackage.haskell.org/package/git-annex-10.20261113/git-annex-10.20261113.tar.gz"
  sha256 "af4add021bac4e9e9bc3087529837bb2291509dd1aae116b5dec754b36ebdf6b"
  license all_of: ["AGPL-3.0-or-later", "BSD-2-Clause", "BSD-3-Clause",
                   "GPL-2.0-only", "GPL-3.0-or-later", "MIT"]
  compatibility_version 1
  head "git://git-annex.branchable.com/", branch: "master"

  livecheck do
    url "https://hackage.haskell.org/package/git-annex"
    regex(/href=.*?git-annex[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "e99f40484a32de79aca8d409a250631f8a25104798d9b0ec7c5995418dcbef6c"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "pkgconf" => :build
  depends_on "botan"
  depends_on "gmp"
  depends_on "libmagic"
  depends_on "sqlite"

  uses_from_macos "libffi"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def args
    [
      # Workaround to build with GHC 9.14
      "--allow-newer=base,template-haskell",
      # Workaround build failing if memory flag falls back to negated resolution
      "--constraint=aws<0.25.3",
      # Unbundle sqlite
      "--constraint=persistent-sqlite +systemlib +use-pkgconfig",
    ]
  end

  def fetch
    system "cabal", "v2-update"
    system "cabal", "v2-install", "--only-download", *args, *std_cabal_v2_args
  end

  def install
    system "cabal", "v2-install", *args, *std_cabal_v2_args
    bin.install_symlink "git-annex" => "git-annex-shell"
    bin.install_symlink "git-annex" => "git-remote-annex"
    bin.install_symlink "git-annex" => "git-remote-tor-annex"
  end

  service do
    run [opt_bin/"git-annex", "assistant", "--autostart"]
  end

  test do
    # make sure git can find git-annex
    ENV.prepend_path "PATH", bin

    system "git", "init"
    system "git", "annex", "init"
    (testpath/"Hello.txt").write "Hello!"
    refute_predicate (testpath/"Hello.txt"), :symlink?
    assert_match(/^add Hello.txt.*ok.*\(recording state in git\.\.\.\)/m, shell_output("git annex add ."))
    system "git", "commit", "-a", "-m", "Initial Commit"
    assert_predicate (testpath/"Hello.txt"), :symlink?

    # make sure the various remotes were built
    assert_match "remote types: git gcrypt p2p S3 bup directory rsync web bittorrent " \
                 "webdav adb tahoe glacier ddar git-lfs httpalso borg rclone hook external",
                 shell_output("git annex version | grep 'remote types:'").chomp

    # The steps below are necessary to ensure the directory cleanly deletes.
    # git-annex guards files in a way that isn't entirely friendly of automatically
    # wiping temporary directories in the way `brew test` does at end of execution.
    system "git", "rm", "Hello.txt", "-f"
    system "git", "commit", "-a", "-m", "Farewell!"
    system "git", "annex", "unused"
    assert_match "dropunused 1 ok", shell_output("git annex dropunused 1 --force")
    system "git", "annex", "uninit"
  end
end
