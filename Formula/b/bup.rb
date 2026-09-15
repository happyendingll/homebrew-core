class Bup < Formula
  desc "Backup tool"
  homepage "https://bup.github.io/"
  url "https://github.com/bup/bup/archive/refs/tags/0.34.tar.gz"
  sha256 "ab790f39e53bee9570f17c58d22e4bc03246f25d45e12cc1b7b5f2bef6d14611"
  license all_of: ["BSD-2-Clause", "LGPL-2.0-only"]
  head "https://github.com/bup/bup.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any, sequoia: "5a225dbece2cc222423cb74d4d7f1d6b589bb8cb7fd6d59adf550d6f4e76cc50"
  end

  depends_on "pandoc" => :build
  depends_on "pkgconf" => :build

  depends_on "python@3.14"
  depends_on "readline"

  on_macos do
    depends_on "bash" => :build # config_cflags[@]: unbound variable
    depends_on "make" => :build # Depends on `make` >= 4.2
  end

  on_linux do
    depends_on "acl"
  end

  def install
    ENV["BUP_PYTHON_CONFIG"] = "#{python3}-config"

    # Call `make` as `gmake` to use Homebrew `make`.
    system "gmake", "PREFIX=#{prefix}", "install"
  end

  test do
    system bin/"bup", "init"
    assert_path_exists testpath/".bup"
  end
end
