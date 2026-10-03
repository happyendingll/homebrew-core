class Genact < Formula
  desc "Nonsense activity generator"
  homepage "https://svenstaro.github.io/genact/"
  url "https://github.com/svenstaro/genact/archive/refs/tags/v1.6.0.tar.gz"
  sha256 "bff905d0717cd8d5567cca3a81b718b64e0c965b6a49b119bb83b6726858e31d"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "d11d0b2b5fd7800493b2082b69b894bf6acf226bc2c1acf4153262429799b151"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"genact", "--print-completions")
  end

  test do
    assert_match "Available modules:", shell_output("#{bin}/genact --list-modules")
  end
end
