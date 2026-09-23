class Secretspec < Formula
  desc "Declarative secrets management tool"
  homepage "https://secretspec.dev"
  url "https://github.com/cachix/secretspec/archive/refs/tags/v0.21.0.tar.gz"
  sha256 "fa24f785bae57f6005b306493d5546002d08d71a42da6daf0cecd7a917e0b004"
  license "Apache-2.0"
  head "https://github.com/cachix/secretspec.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "6a0b411436953fe894ed3c41bac19f5a6e17f682fc2cc14976b572d159e43cce"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "dbus"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "secretspec")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/secretspec --version")
    system bin/"secretspec", "init"
    assert_path_exists testpath/"secretspec.toml"
  end
end
