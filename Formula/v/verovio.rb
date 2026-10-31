class Verovio < Formula
  desc "Command-line MEI music notation engraver"
  homepage "https://www.verovio.org"
  url "https://github.com/rism-digital/verovio/archive/refs/tags/version-6.4.0.tar.gz"
  sha256 "8c36565ba46d37c184d4a1265e9a8b3bd0db854c7f0b77bbf448fd7c5968c1f6"
  license "LGPL-3.0-only"
  head "https://github.com/rism-digital/verovio.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 sequoia: "2f942b11be23de7c961be5b8b0b3a5f1546147fd376be39a7bd0adc697496ff9"
  end

  depends_on "cmake" => :build

  resource "homebrew-testdata", :test do
    url "https://www.verovio.org/examples/downloads/Ahle_Jesu_meines_Herzens_Freud.mei"
    sha256 "79e6e062f7f0300e8f0f4364c4661835a0baffc3c1468504a555a5b3f9777cc9"
  end

  allow_network_access! :test

  def install
    system "cmake", "-S", "./cmake", "-B", "tools", *std_cmake_args
    system "cmake", "--build", "tools"
    system "cmake", "--install", "tools"
  end

  test do
    system bin/"verovio", "--version"
    resource("homebrew-testdata").stage do
      shell_output("#{bin}/verovio Ahle_Jesu_meines_Herzens_Freud.mei -o #{testpath}/output.svg")
    end
    assert_path_exists testpath/"output.svg"
  end
end
