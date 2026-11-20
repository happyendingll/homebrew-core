class Resticprofile < Formula
  desc "Configuration profiles manager and scheduler for restic backup"
  homepage "https://creativeprojects.github.io/resticprofile/"
  url "https://github.com/creativeprojects/resticprofile/archive/refs/tags/v0.35.0.tar.gz"
  sha256 "890e768a98948a85f5f7594a666784159209423f3688bf87b3f9c103b3c735f7"
  license "GPL-3.0-only"
  head "https://github.com/creativeprojects/resticprofile.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "48ca927a37100f11287618ee54be22680798856d6e1818cc65264ef2d238eacb"
  end

  depends_on "go" => :build
  depends_on "restic"

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser, tags: "no_self_update")

    bash_completion.install "contrib/completion/bash-completion.sh" => "resticprofile"
    fish_completion.install "contrib/completion/fish-completion.fish" => "resticprofile.fish"
    zsh_completion.install "contrib/completion/zsh-completion.zsh" => "_resticprofile"
  end

  test do
    (testpath/"repository").mkpath
    (testpath/"password.txt").write shell_output("#{bin}/resticprofile generate --random-key").strip
    (testpath/"profiles.toml").write <<~TOML
      [default]
      repository = "local:#{testpath}/repository"
      password-file = "#{testpath}/password.txt"
    TOML

    (testpath/"file.txt").write "Hello, Homebrew!"

    system bin/"resticprofile", "init"
    system bin/"resticprofile", "backup", "file.txt"
    system bin/"resticprofile", "check"
    system bin/"resticprofile", "restore", "latest", "--target", "restored"

    assert_equal (testpath/"file.txt").read, (testpath/"restored/file.txt").read
  end
end
