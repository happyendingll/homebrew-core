class Topiary < Formula
  desc "Uniform formatter for simple languages, as part of the Tree-sitter ecosystem"
  homepage "https://topiary.tweag.io/"
  url "https://github.com/topiary/topiary/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "203bdc6007989f51ef728424c7e051da2c131c0415fc76fb359da8fc49b8006e"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any_skip_relocation, sequoia: "0fe46dde8b9b9378cccedd72b33f97ca1083da33db30d75394d45c7d63bcff28"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "topiary-cli")

    generate_completions_from_executable(bin/"topiary", "completion")
    share.install "topiary-queries/queries"
  end

  test do
    ENV["TOPIARY_LANGUAGE_DIR"] = share/"queries"

    (testpath/"test.rs").write <<~RUST
      fn main() {
        println!("Hello, world!");
      }
    RUST

    system bin/"topiary", "format", testpath/"test.rs"

    assert_match <<~RUST, File.read("#{testpath}/test.rs")
      fn main() {
          println!("Hello, world!");
      }
    RUST

    assert_match version.to_s, shell_output("#{bin}/topiary --version")
  end
end
