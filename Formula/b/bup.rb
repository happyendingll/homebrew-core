class Bup < Formula
  desc "Backup tool"
  homepage "https://bup.github.io/"
  url "https://github.com/bup/bup/archive/refs/tags/0.34.1.tar.gz"
  sha256 "3ffe5c8bf9da8c291972939959517f98b41f7c62476557bcc00ffa6b54752fe4"
  license all_of: ["BSD-2-Clause", "LGPL-2.0-only"]
  head "https://github.com/bup/bup.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-6"
    sha256 cellar: :any, sequoia: "765596ea78e8c8075c6dd44b28dc8e6d5fa9f16952d0143e3698dbf398b9d711"
  end

  depends_on "pandoc" => :build
  depends_on "pkgconf" => :build

  depends_on "python@3.15"
  depends_on "readline"

  on_macos do
    depends_on "bash" => :build # config_cflags[@]: unbound variable
    depends_on "make" => :build # Depends on `make` >= 4.2
  end

  on_linux do
    depends_on "acl"
  end

  deny_network_access!

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
