class Sabiql < Formula
  desc "Fast, safe-by-design, driverless, Vim-first DB TUI with ER diagrams"
  homepage "https://github.com/riii111/sabiql"
  url "https://github.com/riii111/sabiql/archive/refs/tags/v3.1.0.tar.gz"
  sha256 "c2a0ca871891518f875400947ab550230d34f670767b5108215ccb5f460319ea"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any_skip_relocation, sequoia: "f4398547e3516d491d4c0cf6e38c8d8e7221a24cc75564f4585f4544212fae48"
  end

  depends_on "rust" => :build

  uses_from_macos "sqlite"

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked"
  end

  def install
    system "cargo", "install", "--no-default-features", *std_cargo_args
  end

  def caveats
    <<~EOS
      PostgreSQL and MySQL support require psql or mysql in PATH.
      ER diagram export requires Graphviz in PATH.
    EOS
  end

  test do
    # sabiql is a TUI application, so only its non-interactive CLI behavior is tested.
    assert_match version.to_s, shell_output("#{bin}/sabiql --version")
    output = shell_output("#{bin}/sabiql update 2>&1", 1)
    assert_match "brew upgrade sabiql", output
  end
end
