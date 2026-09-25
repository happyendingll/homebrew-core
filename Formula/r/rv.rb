class Rv < Formula
  desc "Ruby version manager"
  homepage "https://github.com/spinel-coop/rv"
  url "https://github.com/spinel-coop/rv/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "a88bf0edc2ddb14c90e59a845fc8c9b3b26af236764fdfbef368bb0b33a395ea"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/spinel-coop/rv.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, sequoia: "60ec302400f0e7c33f1ed635519640d1326da0d634d9e83f57ed3dc0050bb04b"
  end

  depends_on "rust" => :build

  uses_from_macos "llvm" => :build # for libclang

  on_macos do
    depends_on macos: :sonoma
  end

  conflicts_with "rv-r", because: "both install `rv` binary"

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/rv")
    generate_completions_from_executable(bin/"rv", "shell", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rv --version")
    assert_match "No Ruby installations found.", shell_output("#{bin}/rv ruby list --installed-only 2>&1")
    (testpath/"hello.rb").write <<~RUBY
      puts "Homebrew"
    RUBY
    assert_match "Homebrew", shell_output("#{bin}/rv run --ruby 3.4.5 hello.rb")
  end
end
