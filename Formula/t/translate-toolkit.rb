class TranslateToolkit < Formula
  include Language::Python::Virtualenv

  desc "Toolkit for localization engineers"
  homepage "https://toolkit.translatehouse.org/"
  url "https://files.pythonhosted.org/packages/dc/8f/618a8b6589e67232feecbda4094fbfa3e076cdabd146519960453ea18b44/translate_toolkit-3.20.1.tar.gz"
  sha256 "8626ab3def40f9db15e0481cf6afcd22aa15f1f12670608a0bcbca57777a2d0c"
  license "GPL-3.0-or-later"
  head "https://github.com/translate/translate.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any, sequoia: "a45360ccffcfa0de5a3e1e0580dc8a3af6daedf090331d28beac8968b09b72f2"
  end

  depends_on "rust" => :build # for `unicode_segmentation_py`
  depends_on "python@3.15"

  uses_from_macos "libxml2", since: :ventura
  uses_from_macos "libxslt"

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/23/ad/28ecd7cb894d172f3c9c80a075eeeb2017ac62e3632cee05a5f9493547eb/lxml-6.1.3.tar.gz"
    sha256 "45222d94ddd511536f3b2f7d9deae3b2339b4ce0f075f1ca25703b07cad9dd21"
  end

  resource "unicode-segmentation-rs" do
    url "https://files.pythonhosted.org/packages/26/e4/28a415f71c7fe00f6b22254b3890442955bc720918c95d7b0c3ea0f5e12b/unicode_segmentation_rs-1.0.0.tar.gz"
    sha256 "0c813bd38ab6bce5176f65d3b7c13b5d771f02dac09c09ff55ceb39728a995ee"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    test_file = testpath/"test.po"
    touch test_file
    assert_match "Processing file : #{test_file}", shell_output("#{bin}/pocount --no-color #{test_file}")

    assert_match version.to_s, shell_output("#{bin}/pretranslate --version")
    assert_match version.to_s, shell_output("#{bin}/podebug --version")
  end
end
