class Gitnr < Formula
  desc "Create `.gitignore` using templates from TopTal, GitHub or your own collection"
  homepage "https://github.com/reemus-dev/gitnr"
  url "https://github.com/reemus-dev/gitnr/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "06b1ab4a5ff56c815162485a9d90aae1d72b0c042f9be15b7db20c210a80f378"
  license "MIT"
  head "https://github.com/reemus-dev/gitnr.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "6b18fb022b212c42577c960165ee330ff4947d01ede3866ac2d1c263412eef32"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"

  def install
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")
    system "cargo", "install", *std_cargo_args
  end

  test do
    system bin/"gitnr create gh:Rust"

    system bin/"gitnr create gh:Rust > #{testpath}/.gitignore.rust"
    assert_path_exists testpath/".gitignore.rust"
  end
end
