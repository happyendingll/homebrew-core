class Spaceship < Formula
  desc "Zsh prompt for Astronauts"
  homepage "https://spaceship-prompt.sh/"
  url "https://github.com/spaceship-prompt/spaceship-prompt/archive/refs/tags/v4.22.6.tar.gz"
  sha256 "02da1413520241668141041f82284410dad5d3b4379a4d21b346ee206ee5f2be"
  license "MIT"
  head "https://github.com/spaceship-prompt/spaceship-prompt.git", branch: "master"

  no_autobump! because: :bumped_by_upstream

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "865d7e142dd160b37d84ab6eeed4212c12f584c41a7884eb9ec748971059b5df"
  end

  depends_on "zsh-async"
  uses_from_macos "zsh" => :test

  def install
    system "make", "compile"
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To activate Spaceship, add the following line to ~/.zshrc:
        source "#{opt_prefix}/spaceship.zsh"
      If your .zshrc sets ZSH_THEME, remove that line.
    EOS
  end

  test do
    # sourcing exits non-zero when `zcompile` cannot write beside the read-only keg, so check the prompt hook instead
    assert_match "SUCCESS",
      shell_output("zsh -fc '. #{opt_prefix}/spaceship.zsh 2>/dev/null; " \
                   "(( ${precmd_functions[(I)prompt_spaceship_precmd]} )) && echo SUCCESS'")
  end
end
