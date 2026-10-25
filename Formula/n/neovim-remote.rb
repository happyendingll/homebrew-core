class NeovimRemote < Formula
  include Language::Python::Virtualenv

  desc "Control nvim processes using `nvr` command-line tool"
  homepage "https://github.com/mhinz/neovim-remote"
  url "https://files.pythonhosted.org/packages/69/50/4fe9ef6fd794929ceae73e476ac8a4ddbf3b0913fa248d834c9bb72978b7/neovim-remote-2.5.1.tar.gz"
  sha256 "4b3cc35463544c5747c895c52a0343cfdbba15d307647d7f57f1cce0c6a27d02"
  license "MIT"
  revision 6
  head "https://github.com/mhinz/neovim-remote.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "c9d03bc10f109bc962ab54e160ebdc6928d97b6065e557665e60b85af7d0ddb6"
  end

  depends_on "neovim"
  depends_on "python@3.15"

  resource "greenlet" do
    url "https://files.pythonhosted.org/packages/3e/6e/0091f175ccd02b02bc8811bbcbcc6ac2e980be116e3b2f7a736ca322bf84/greenlet-3.5.6.tar.gz"
    sha256 "8e67c43bdfc88d5fee6db0d3e40175b362fc95fb85f0412d233b9b203c53a575"
  end

  resource "msgpack" do
    url "https://files.pythonhosted.org/packages/0a/e7/bb605a7bab2d8425a64b3fa762b39dc1bf1c7e3f11ba6fb5413d6db0ff8c/msgpack-1.2.3.tar.gz"
    sha256 "32edb81a2b5eb7cd7c9d941b2bfbbb082fd2cd09e0e725930316af6b708db186"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  resource "pynvim" do
    url "https://files.pythonhosted.org/packages/04/d7/c4412e6219661fd8689cdd9553988f8ea38c151067d70c49436977688aa9/pynvim-0.6.0.tar.gz"
    sha256 "0ffcb879322d08f9e9061e1123dd58ba3a5ccfbd4999bb1157bac525822aa590"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/70/b3/c19426f783614d625699a4b247faf628ea9ab1db228674491767b417f9e1/setuptools-84.2.1.tar.gz"
    sha256 "3ff8b3b5492a0aa66960f4419365a86b84e013070d4313e4d4a6894f5d64d6bc"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    socket = testpath/"nvimsocket"
    file = testpath/"test.txt"

    nvim = spawn(
      formula_opt_bin("neovim")/"nvim", "--headless", "-i", "NONE", "-u", "NONE", "--listen", socket, file,
      [:out, :err] => "/dev/null"
    )
    sleep 1 until socket.exist? && socket.socket?

    str = "Hello from neovim-remote!"
    system bin/"nvr", "--servername", socket, "--remote-send", "i#{str}<ESC>:write<CR>"
    assert_equal str, file.read.chomp
    assert_equal Process.kill(0, nvim), 1

    system bin/"nvr", "--servername", socket, "--remote-send", ":quit<CR>"

    # Test will be terminated by the timeout
    # if `:quit` was not sent correctly
    Process.wait nvim
  end
end
