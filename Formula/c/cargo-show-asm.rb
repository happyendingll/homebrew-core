class CargoShowAsm < Formula
  desc "Show assembly, LLVM-IR, MIR, and WASM generated for Rust code"
  homepage "https://github.com/pacak/cargo-show-asm"
  url "https://github.com/pacak/cargo-show-asm/archive/refs/tags/0.2.63.tar.gz"
  sha256 "d391fdea08cfd4e4638299ecfb86b56ef910b3f79f72462485b6e0713adefa29"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/pacak/cargo-show-asm.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "d6160b42448d06ef428e865c0ee33c0d43872d7d91026cd100343691d166545a"
  end

  depends_on "rust" => :build
  depends_on "rustup" => :test

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    ENV.prepend_path "PATH", formula_opt_bin("rustup")
    system "rustup", "set", "profile", "minimal"
    system "rustup", "default", "stable"
    system "cargo", "new", "test_asm", "--lib"
    cd "test_asm" do
      rm testpath/"test_asm/src/lib.rs"
      (testpath/"test_asm/src/lib.rs").write <<~RUST
        #[inline(never)]
        pub fn hello() -> &'static str {
            "Hello"
        }
      RUST
      output = shell_output("#{bin}/cargo-asm asm --lib hello 2>&1")
      assert_match "test_asm::hello", output
    end
  end
end
