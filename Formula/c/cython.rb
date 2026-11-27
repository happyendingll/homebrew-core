class Cython < Formula
  include Language::Python::Virtualenv

  desc "Compiler for writing C extensions for the Python language"
  homepage "https://cython.org/"
  url "https://files.pythonhosted.org/packages/98/de/dff7f5fcfd06a947b16bbd66568e3e8f291cd9a17c35fd04b43b5a7ad3bf/cython-3.3.2.tar.gz"
  sha256 "e789d9fd939b74fb8c572fc2b689e3b14bd141ba95243693a546064c8179a1d3"
  license "Apache-2.0"
  compatibility_version 1
  head "https://github.com/cython/cython.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any_skip_relocation, sequoia: "71b9a892ffd58e7edfd7e0e22693d5b8792887fcc52e59569857cbf409f10e93"
  end

  depends_on "python@3.15"

  # https://github.com/cython/cython/issues/5976
  pypi_packages extra_packages: "setuptools"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/70/b3/c19426f783614d625699a4b247faf628ea9ab1db228674491767b417f9e1/setuptools-84.2.1.tar.gz"
    sha256 "3ff8b3b5492a0aa66960f4419365a86b84e013070d4313e4d4a6894f5d64d6bc"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    phrase = "You are using Homebrew"
    (testpath/"example.pyx").write "print '#{phrase}'"

    system bin/"cythonize", "--inplace", "example.pyx"
    assert_match phrase, shell_output("#{libexec}/bin/python -c 'import example'")
  end
end
