class Linecast < Formula
  include Language::Python::Virtualenv

  desc "Weather, tides, the sun, the moon, and maps, drawn for the terminal"
  homepage "https://github.com/ashuttl/linecast"
  url "https://files.pythonhosted.org/packages/f0/c7/44a2cc304a71ea2934cd735b4fd290fe98ee870a88184c06c52a16a3f2ba/linecast-2.9.3.tar.gz"
  sha256 "cda8376f0b5e35b84b5845dee20b1d3631969202eada90f102c6153c681297e8"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "5c3430b8aeb6cf5db92bb77f99c276d95cf1cf18614c6dda4b7852db1b1849b9"
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
