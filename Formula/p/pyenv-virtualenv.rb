class PyenvVirtualenv < Formula
  desc "Pyenv plugin to manage virtualenv"
  homepage "https://github.com/pyenv/pyenv-virtualenv"
  url "https://github.com/pyenv/pyenv-virtualenv/archive/refs/tags/v1.4.1.tar.gz"
  sha256 "cbe485abbf05c3d2e8b3c6ae0babca361e173dcd73f76c8cffdc11b0273c7d83"
  license "MIT"
  version_scheme 1
  head "https://github.com/pyenv/pyenv-virtualenv.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "c2cccf2812d964bc6866a4a84851394587cc7ca21fa032e1aa3a43a0271b103c"
  end

  depends_on "pyenv"

  on_macos do
    # `readlink` on macOS Big Sur and earlier doesn't support the `-f` option
    depends_on "coreutils"
  end

  deny_network_access!

  def install
    ENV["PREFIX"] = prefix
    system "./install.sh"

    # macOS Big Sur and earlier do not support `readlink -f`
    inreplace bin/"pyenv-virtualenv-prefix", "readlink", "#{formula_opt_bin("coreutils")}/greadlink" if OS.mac?
  end

  test do
    shell_output("eval \"$(pyenv init -)\" && pyenv virtualenvs")
  end
end
