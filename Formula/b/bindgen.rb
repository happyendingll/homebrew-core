class Bindgen < Formula
  desc "Automatically generates Rust FFI bindings to C (and some C++) libraries"
  homepage "https://rust-lang.github.io/rust-bindgen/"
  url "https://github.com/rust-lang/rust-bindgen/archive/refs/tags/v0.73.2.tar.gz"
  sha256 "5fc3277dd334e4bbbd7bdb8cad5d4fb87a667b2e95a2bae350a8d5424c280629"
  license "BSD-3-Clause"
  head "https://github.com/rust-lang/rust-bindgen.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "f0b6358ef9c3ba3a77b9b5a31e3be0dd53ec98f5446ec803212d0e8ea5e2e549"
  end

  depends_on "rust" => :build

  uses_from_macos "llvm" # for libclang

  def install
    system "cargo", "install", *std_cargo_args(path: "bindgen-cli")

    generate_completions_from_executable(bin/"bindgen", "--generate-shell-completions",
                                                        shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    (testpath/"cool.h").write <<~C
      typedef struct CoolStruct {
          int x;
          int y;
      } CoolStruct;

      void cool_function(int i, char c, CoolStruct* cs);
    C

    output = shell_output("#{bin}/bindgen cool.h")
    assert_match "pub struct CoolStruct", output

    assert_match version.to_s, shell_output("#{bin}/bindgen --version")
  end
end
