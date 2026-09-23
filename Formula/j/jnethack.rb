class Jnethack < Formula
  desc "Japanese localization of NetHack"
  homepage "https://github.com/jnethack/jnethack-release"
  # We use a git checkout to avoid patching the upstream NetHack tarball.
  url "https://github.com/jnethack/jnethack-release.git",
      tag:      "v3.6.7-0.2",
      revision: "3f3a1afbdf51473d9c7a55f78d351b435707b751"
  license "NGPL"
  head "https://github.com/jnethack/jnethack-release.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 sequoia: "93522b9a13c451f2d0decc39f05440cf3a0adc63fef33ee6040fa5712daee875"
  end

  depends_on "nkf" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "ncurses"

  # Don't remove save folder
  skip_clean "libexec/save"

  def install
    # Build everything in-order; no multi builds.
    ENV.deparallelize
    ENV.O0

    # Enable wizard mode for all users
    inreplace "sys/unix/sysconf", /^WIZARDS=.*/, "WIZARDS=*"

    platform = OS.mac? ? "macosx10.10" : OS.kernel_name.downcase

    # Only this file is touched by jNetHack, so don't switch on macOS versions
    inreplace "sys/unix/hints/#{platform}" do |s|
      # macOS clang doesn't support code page 932
      s.gsub! "-fexec-charset=cp932", "" if OS.mac?
      s.change_make_var! "HACKDIR", libexec
      s.change_make_var! "CHOWN", "true"
      s.change_make_var! "CHGRP", "true"
      # Setting VAR_PLAYGROUND preserves saves across upgrades. With a bit of
      # work this could share leaderboards with English NetHack, however bones
      # and save files are much tricker. We could set those separately but
      # it's probably not worth the extra trouble. New curses backend is not
      # supported by jNetHack.
      replace_string = OS.mac? ? "#WANT_WIN_CURSES=1" : "#CFLAGS+=-DEXTRA_SANITY_CHECKS"
      s.gsub! replace_string, "CFLAGS+=-DVAR_PLAYGROUND='\"#{HOMEBREW_PREFIX}/share/jnethack\"'"
    end

    # We use the Linux version due to code page 932 issues, but point the
    # hints file to macOS
    inreplace "japanese/set_lnx.sh", "linux", "macosx10.10" if OS.mac?
    system "sh", "japanese/set_lnx.sh"
    system "make", "install"
    bin.install_symlink libexec/"jnethack"
  end

  post_install_steps do
    mkdir_p "{{HOMEBREW_PREFIX}}/share/jnethack/save"
    touch "{{HOMEBREW_PREFIX}}/share/jnethack/xlogfile"
    touch "{{HOMEBREW_PREFIX}}/share/jnethack/logfile"
    touch "{{HOMEBREW_PREFIX}}/share/jnethack/perm"
    touch "{{HOMEBREW_PREFIX}}/share/jnethack/record"
    touch "{{HOMEBREW_PREFIX}}/share/jnethack/save/.keepme"
    set_permissions ["{{HOMEBREW_PREFIX}}/share/jnethack", "{{HOMEBREW_PREFIX}}/share/jnethack/save"], "g+w",
                    recursive: false
  end

  test do
    system bin/"jnethack", "-s"
    assert_match (HOMEBREW_PREFIX/"share/jnethack").to_s,
      shell_output("#{bin}/jnethack --showpaths")
  end
end
