class Rv < Formula
  desc "Ruby version manager"
  homepage "https://github.com/spinel-coop/rv"
  url "https://github.com/spinel-coop/rv/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "3336a90e0cd559b8ba6b1887f51df78a0fb74e0e8abe858686c80e31f67fa29d"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/spinel-coop/rv.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "0e6c788d03804d8a4feac83807f6dd2d1612fd13a1855fadef96589a12e3620c"
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
