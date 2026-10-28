class Virtualenv < Formula
  include Language::Python::Virtualenv

  desc "Tool for creating isolated virtual python environments"
  homepage "https://virtualenv.pypa.io/"
  url "https://files.pythonhosted.org/packages/ee/00/c27937345311d2aaf6197203231a59010073d7abffae3971503ac0e65477/virtualenv-21.15.0.tar.gz"
  sha256 "41a0cfec413c886a991bf7657d02f8996e69e192485aa127b410f29f1e35cfd3"
  license "MIT"
  head "https://github.com/pypa/virtualenv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1a4ebc633317ad3a6c4b4ba6bb4619cf86113265fa80d88d786c62adde6ab500"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1a4ebc633317ad3a6c4b4ba6bb4619cf86113265fa80d88d786c62adde6ab500"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1a4ebc633317ad3a6c4b4ba6bb4619cf86113265fa80d88d786c62adde6ab500"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "995d3b4146512b908ed6496fef4a6e0d466829b55a50f4a39237de83c3b8df0d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "995d3b4146512b908ed6496fef4a6e0d466829b55a50f4a39237de83c3b8df0d"
  end

  depends_on "python@3.15"

  resource "distlib" do
    url "https://files.pythonhosted.org/packages/68/bc/d36966de7304047a1001a7559fbf266c464bb5d8cc85464536ef8c9bcc32/distlib-0.4.4.tar.gz"
    sha256 "ca4175b4ac7f71223cc30ed7248c45d2b38c2439d8ee6e498ab67ed63cf3508d"
  end

  resource "filelock" do
    url "https://files.pythonhosted.org/packages/d8/28/3893324bcadf8f89b1616637468d766af3f625008c0735bf704fdfa86617/filelock-4.2.4.tar.gz"
    sha256 "c6d8663535e1650ee430507b4ffbac7b464dd64b7647ea0112a9f406499d163d"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/7d/fa/3944b40b07da9ce895c0e6303a5ab7d53da063554f534556b134a54d6093/packaging-26.3.tar.gz"
    sha256 "94edc256424af38762eb31306eed28beb9f0efc50a8837492c9d6fd6004aed79"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/1a/43/8c4b5fe23f0e119cf4e1b16c2d16240ab9057cdbb138568c91d5a48abf81/platformdirs-4.13.6.tar.gz"
    sha256 "211d176e24674b5895dedf9021c262bcf9fad008a70610bfb147d4a8d6d8fe1b"
  end

  resource "python-discovery" do
    url "https://files.pythonhosted.org/packages/b7/ba/2bdce36c8f1b081db630c61b433fcc7efa5094ba621147923232bdaa7332/python_discovery-1.6.5.tar.gz"
    sha256 "f9420b2107a429ec9912bd10039135fc9bb8f15e99a00e614533977529f56bb3"
  end

  allow_network_access! :build

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"virtualenv", "venv_dir"
    assert_match "venv_dir", shell_output("venv_dir/bin/python -c 'import sys; print(sys.prefix)'")
  end
end
