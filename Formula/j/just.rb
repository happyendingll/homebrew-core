class Just < Formula
  desc "Handy way to save and run project-specific commands"
  homepage "https://just.systems"
  url "https://github.com/casey/just/archive/refs/tags/1.59.0.tar.gz"
  sha256 "20f876880851f1cc67fc7eb7589c7f7ccaa7612d827feac75797cf4a6ed729aa"
  license "CC0-1.0"
  compatibility_version 1
  head "https://github.com/casey/just.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any_skip_relocation, sequoia: "547e4a10991ddcc9c5a0268c2a5cd75b20dd7ca2988500fbb90daeb649baf079"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"just", shell_parameter_format: "--completions=")
    (man1/"just.1").write Utils.safe_popen_read(bin/"just", "--man")
  end

  test do
    (testpath/"justfile").write <<~MAKE
      default:
        touch it-worked
    MAKE
    system bin/"just"
    assert_path_exists testpath/"it-worked"

    assert_match version.to_s, shell_output("#{bin}/just --version")
  end
end
