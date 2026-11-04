class Verovio < Formula
  desc "Command-line MEI music notation engraver"
  homepage "https://www.verovio.org"
  url "https://github.com/rism-digital/verovio/archive/refs/tags/version-6.4.1.tar.gz"
  sha256 "401e555ab19825d6843f662c8d4e40a310f0f63f349461d24b685d6e32209fbc"
  license "LGPL-3.0-only"
  head "https://github.com/rism-digital/verovio.git", branch: "develop"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 sequoia: "874a1a025d1bfa312f654585f1b0c3f72c5814c04290b40e7d434046f397a8ad"
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
