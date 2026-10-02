class Tox < Formula
  include Language::Python::Virtualenv

  desc "Generic Python virtualenv management and test command-line tool"
  homepage "https://tox.wiki/en/latest/"
  url "https://files.pythonhosted.org/packages/10/67/2da6f606bb435002c802aaf3cd7a39ccbe326048a5eb661f6afc260c6cf6/tox-4.64.6.tar.gz"
  sha256 "012085b423d10577fa9214542618b99e97fc65398b61ca4524ef86283881ed5f"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d63c6993d70505ebbd7bf638441d2f39f4018202a2eb2aed63c5e28a43860c2f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d63c6993d70505ebbd7bf638441d2f39f4018202a2eb2aed63c5e28a43860c2f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d63c6993d70505ebbd7bf638441d2f39f4018202a2eb2aed63c5e28a43860c2f"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "e72c839d9cab42c338ca0d4937e3ad34569e3e2ab04574de61f63d5bd672856d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "e72c839d9cab42c338ca0d4937e3ad34569e3e2ab04574de61f63d5bd672856d"
  end

  depends_on "python@3.14"

  resource "cachetools" do
    url "https://files.pythonhosted.org/packages/29/2c/3f18755527b03ca9ff6be724bd5370cb777c76a87f17301377cf04a4729b/cachetools-7.2.0.tar.gz"
    sha256 "bcac1a1b8da6909994a2957238a57b8140dab7c5c5c69a43669654fe87a33c1d"
  end

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/d8/53/6f443c9a4a8358a93a6792e2acffb9d9d5cb0a5cfd8802644b7b1c9a02e4/colorama-0.4.6.tar.gz"
    sha256 "08695f5cb7ed6e0531a20572697297273c47b8cae5a63ffc6d6ed5c201be6e44"
  end

  resource "distlib" do
    url "https://files.pythonhosted.org/packages/c9/02/bd72be9134d25ed783ecbbc38a539ffaefbf90c78418c7fb7229600dbac7/distlib-0.4.3.tar.gz"
    sha256 "f152097224a0ae24be5a0f6bae1b9359af82133bce63f98a95f86cae1aede9ed"
  end

  resource "filelock" do
    url "https://files.pythonhosted.org/packages/cc/19/d4f21fc4b7ad098dd3c774ccb2a2929178b15d6e1a3ba7d0929817c0b30c/filelock-4.0.8.tar.gz"
    sha256 "733d9b6b153fc63672f86104324186818b6bbe9dd7db84e9bb9887b6a04a2775"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/7d/fa/3944b40b07da9ce895c0e6303a5ab7d53da063554f534556b134a54d6093/packaging-26.3.tar.gz"
    sha256 "94edc256424af38762eb31306eed28beb9f0efc50a8837492c9d6fd6004aed79"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/17/c8/721b3855fe457da514fe249247d404b9b39c5d16532278f70ebaa6acf18b/platformdirs-4.12.2.tar.gz"
    sha256 "eab5f70271a490ef74618bb314fbb86e3c7e82fa3b9c922c2ea0e0a1a155d329"
  end

  resource "pluggy" do
    url "https://files.pythonhosted.org/packages/f9/e2/3e91f31a7d2b083fe6ef3fa267035b518369d9511ffab804f839851d2779/pluggy-1.6.0.tar.gz"
    sha256 "7dcc130b76258d33b90f61b658791dede3486c3e6bfb003ee5c9bfb396dd22f3"
  end

  resource "pyproject-api" do
    url "https://files.pythonhosted.org/packages/e1/2d/7b6837335aab9c00bcd18adde43c78948db6a2fe26dfa79a6bfcdefd3c5d/pyproject_api-1.11.2.tar.gz"
    sha256 "7bff8690a101f5f0bac3221475d214018f196ae5eea3af9c9879f4d682a3fd60"
  end

  resource "python-discovery" do
    url "https://files.pythonhosted.org/packages/0c/57/250bd238b966cece44328235eb85290045d059265fdaf7527a3a958123db/python_discovery-1.6.1.tar.gz"
    sha256 "cf87d3627dfb4412437fdd5b13eae402607722998d21567993aedbc59b23c15e"
  end

  resource "tomli-w" do
    url "https://files.pythonhosted.org/packages/19/75/241269d1da26b624c0d5e110e8149093c759b7a286138f4efd61a60e75fe/tomli_w-1.2.0.tar.gz"
    sha256 "2dd14fac5a47c27be9cd4c976af5a12d87fb1f0b4512f81d69cce3b35ae25021"
  end

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/67/57/630a01cf5ab58f33b9c7dc8a7f13464cb5740b5227f8a08cab9d798bd532/virtualenv-21.14.2.tar.gz"
    sha256 "571930928b11e43db690073ad8228162eca8a3f8fd3a87acdeae07df7dd57068"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage", shell_output("#{bin}/tox --help")
    system bin/"tox"
    pyver = Language::Python.major_minor_version(python3).to_s.delete(".")

    system bin/"tox", "quickstart", "src"
    (testpath/"src/test_trivial.py").write <<~PYTHON
      def test_trivial():
          assert True
    PYTHON
    chdir "src" do
      system bin/"tox", "run"
    end
    assert_path_exists testpath/"src/.tox/py#{pyver}"
  end
end
