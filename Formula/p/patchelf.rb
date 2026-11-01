class Patchelf < Formula
  desc "Modify dynamic ELF executables"
  homepage "https://github.com/NixOS/patchelf"
  url "https://github.com/NixOS/patchelf/releases/download/0.19.3/patchelf-0.19.3.tar.bz2"
  sha256 "20dbe23e9dbc4ad769078a867ad002c04297a069ff93c95fb72242dd55d4dd6f"
  license "GPL-3.0-or-later"
  compatibility_version 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any_skip_relocation, sequoia: "fd59c7f714cfa7730b625068aaf2bc324693acf30b7fac6d18cf132cea38229b"
  end

  head do
    url "https://github.com/NixOS/patchelf.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    if OS.linux?
      # Fix ld.so path and rpath
      # see https://github.com/Homebrew/linuxbrew-core/pull/20548#issuecomment-672061606
      ENV["HOMEBREW_DYNAMIC_LINKER"] = File.readlink("#{HOMEBREW_PREFIX}/lib/ld.so")
      ENV["HOMEBREW_RPATH_PATHS"] = nil
    end

    system "./bootstrap.sh" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    cp test_fixtures("elf/hello"), testpath
    assert_equal "/lib64/ld-linux-x86-64.so.2\n", shell_output("#{bin}/patchelf --print-interpreter hello")
    assert_equal "libc.so.6\n", shell_output("#{bin}/patchelf --print-needed hello")
    assert_equal "\n", shell_output("#{bin}/patchelf --print-rpath hello")
    assert_empty shell_output("#{bin}/patchelf --set-rpath /usr/local/lib hello")
    assert_equal "/usr/local/lib\n", shell_output("#{bin}/patchelf --print-rpath hello")
  end
end
