class UutilsCoreutils < Formula
  desc "Cross-platform Rust rewrite of the GNU coreutils"
  homepage "https://uutils.github.io/coreutils/"
  url "https://github.com/uutils/coreutils/archive/refs/tags/0.12.0.tar.gz"
  sha256 "4fb327655cb4ffcbf2f16550cf9234079ffe839692f7aa1a6eda104af684e122"
  license "MIT"
  head "https://github.com/uutils/coreutils.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, sequoia: "00850c3522188a8b36f95298c90ec3c9b9665cadbe64c81d4900158475197587"
  end

  depends_on "rust" => :build
  depends_on "sphinx-doc" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    man1.mkpath

    args = [
      "PROG_PREFIX=uu-",
      "PREFIX=#{prefix}",
      "SPHINXBUILD=#{formula_opt_bin("sphinx-doc")}/sphinx-build",
      "MULTICALL=y",
      "LN=ln -sf",
    ]
    system "make", "install", *args

    # Symlink all commands into libexec/uubin without the 'uu-' prefix
    coreutils_filenames(bin).each do |cmd|
      uu_cmd = bin/"uu-#{cmd}"
      (libexec/"uubin").install_symlink uu_cmd.realpath => cmd
    end

    # Symlink all man(1) pages into libexec/uuman without the 'uu-' prefix
    coreutils_filenames(man1).each do |cmd|
      (libexec/"uuman/man1").install_symlink man1/"uu-#{cmd}" => cmd
    end

    (libexec/"uubin").install_symlink "../uuman" => "man"
  end

  def caveats
    <<~EOS
      Commands have been installed with the prefix "uu-".
      If you need to use these commands with their normal names, you
      can add a "uubin" directory to your PATH from your bashrc like:
        PATH="#{opt_libexec}/uubin:$PATH"
    EOS
  end

  def coreutils_filenames(dir)
    filenames = []
    dir.find do |path|
      next if path.directory? || path.basename.to_s == ".DS_Store"

      filenames << path.basename.to_s.sub(/^uu-/, "")
    end
    filenames.sort
  end

  test do
    (testpath/"test").write("test")
    (testpath/"test.sha1").write("a94a8fe5ccb19ba61c4c0873d391e987982fbbd3 test")
    system bin/"uu-sha1sum", "-c", "test.sha1"
    system bin/"uu-ln", "-f", "test", "test.sha1"
  end
end
