class Virtualenv < Formula
  include Language::Python::Virtualenv

  desc "Tool for creating isolated virtual python environments"
  homepage "https://virtualenv.pypa.io/"
  url "https://files.pythonhosted.org/packages/f5/3e/5a73d53ce67e43d3c1dabfbfcda956d2c840f21c2a65dc7256eaffe5ac38/virtualenv-21.14.4.tar.gz"
  sha256 "d7f167214b3c4f69df5386677dae5091dbc9c400fc46080187ae28064c9d453d"
  license "MIT"
  head "https://github.com/pypa/virtualenv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0092c6a53eefa56b2f12bfd1f61f54c3f16fce9b88e9dc303d42002d9c511854"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "0092c6a53eefa56b2f12bfd1f61f54c3f16fce9b88e9dc303d42002d9c511854"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0092c6a53eefa56b2f12bfd1f61f54c3f16fce9b88e9dc303d42002d9c511854"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "78aec7d9eb794f1f3172d6f7792199f024d02b31115199a7ce4c4103af96d9dd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "78aec7d9eb794f1f3172d6f7792199f024d02b31115199a7ce4c4103af96d9dd"
  end

  depends_on "python@3.14"

  resource "distlib" do
    url "https://files.pythonhosted.org/packages/c9/02/bd72be9134d25ed783ecbbc38a539ffaefbf90c78418c7fb7229600dbac7/distlib-0.4.3.tar.gz"
    sha256 "f152097224a0ae24be5a0f6bae1b9359af82133bce63f98a95f86cae1aede9ed"
  end

  resource "filelock" do
    url "https://files.pythonhosted.org/packages/70/51/2bc9e529f154fad99b6cd0073e609291eb32fd23581b32362d33d164d316/filelock-4.0.9.tar.gz"
    sha256 "635e7d67fa92654eed444e75e9ca18426d34e77ad9c469bf4373f75a932f7b22"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/7d/fa/3944b40b07da9ce895c0e6303a5ab7d53da063554f534556b134a54d6093/packaging-26.3.tar.gz"
    sha256 "94edc256424af38762eb31306eed28beb9f0efc50a8837492c9d6fd6004aed79"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/17/c8/721b3855fe457da514fe249247d404b9b39c5d16532278f70ebaa6acf18b/platformdirs-4.12.2.tar.gz"
    sha256 "eab5f70271a490ef74618bb314fbb86e3c7e82fa3b9c922c2ea0e0a1a155d329"
  end

  resource "python-discovery" do
    url "https://files.pythonhosted.org/packages/0c/57/250bd238b966cece44328235eb85290045d059265fdaf7527a3a958123db/python_discovery-1.6.1.tar.gz"
    sha256 "cf87d3627dfb4412437fdd5b13eae402607722998d21567993aedbc59b23c15e"
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
