class Linecast < Formula
  include Language::Python::Virtualenv

  desc "Weather, tides, the sun, the moon, and maps, drawn for the terminal"
  homepage "https://github.com/ashuttl/linecast"
  url "https://files.pythonhosted.org/packages/ba/ba/227c1df8ac84a934845681095ed54f9d22029b23c43bb19d1739addf244a/linecast-2.8.0.tar.gz"
  sha256 "0f1b7c8ce4a6ef7c31e8180ceb5ed8228685361030e9b33282199dc95940d09a"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "410f6b6ada5121516e7d8d8f795f74c53c63b0b610d8e9a4db6bd00d99a46be5"
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
