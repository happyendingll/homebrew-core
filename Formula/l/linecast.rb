class Linecast < Formula
  include Language::Python::Virtualenv

  desc "Weather, tides, the sun, the moon, and maps, drawn for the terminal"
  homepage "https://github.com/ashuttl/linecast"
  url "https://files.pythonhosted.org/packages/f9/6a/291698e78b775df61d44d70719dc3530dc4019263b27319737f41e60514b/linecast-2.5.1.tar.gz"
  sha256 "704b40e0714d25c62dba7ea2113d928ff513eebbd8845a42afb6ba8c8bcb0fae"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "cc5a4fd8617fe18fa4f7474668283d1a08f2dace421452f9d8ab3cba00299b53"
  end

  depends_on "python@3.14"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/linecast --version")

    output = shell_output("#{bin}/linecast sunshine --location 43.657,-70.258 --json")
    assert_match '"schema": 1', output
    assert_match '"sunrise":', output
    assert_match '"sunset":', output
  end
end
