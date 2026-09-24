class CargoMutants < Formula
  desc "Inject bugs and see if your tests catch them"
  homepage "https://mutants.rs/"
  url "https://github.com/sourcefrog/cargo-mutants/archive/refs/tags/v27.1.0.tar.gz"
  sha256 "e57d8c31a8edee7d9265949aef896768729c824626897938e98a5d162a82bda0"
  license "MIT"
  head "https://github.com/sourcefrog/cargo-mutants.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "9009776767b25f39a0b0b4818ca8b1ac8b2b733798ea2362aa8add01ffcf9a2b"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"cargo-mutants", "mutants", "--completions",
                                         shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "stable"
    system "cargo", "new", "test_mutants", "--lib"
    cd "test_mutants" do
      rm testpath/"test_mutants/src/lib.rs"
      (testpath/"test_mutants/src/lib.rs").write <<~RUST
        pub fn add(a: u32, b: u32) -> u32 {
          a + b
        }

        #[cfg(test)]
        mod tests {
          use super::*;

          #[test]
          fn test_add() {
            assert_eq!(add(2, 3), 5);
          }
        }
      RUST
      output = shell_output("#{bin}/cargo-mutants mutants --list --dir . 2>&1")
      assert_match "src/lib.rs", output
      assert_match(/replace .*add/, output)
      output = shell_output("#{bin}/cargo-mutants mutants --list-files --dir . 2>&1")
      assert_match "src/lib.rs", output
    end
  end
end
