class Lmdb < Formula
  desc "Lightning memory-mapped database: key-value data store"
  homepage "https://www.symas.com/lmdb.php"
  url "https://git.openldap.org/openldap/openldap/-/archive/LMDB_1.0.3/openldap-LMDB_1.0.3.tar.bz2"
  sha256 "015f482ba647e926fbddc9cea49ed59281229c12896cd18675484c36712b98bd"
  license "OLDAP-2.8"
  version_scheme 1
  compatibility_version 1
  head "https://git.openldap.org/openldap/openldap.git", branch: "mdb.master"

  livecheck do
    url :stable
    regex(/^LMDB[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "f14ff11497a283e1ae78741f622d2ef3baec7014ff2d103e5bff3e92a5ae5f6a"
  end

  depends_on "pkgconf" => :test

  def install
    cd "libraries/liblmdb" do
      args = []
      if OS.mac?
        args << "SOEXT=.dylib"
        # Apple's ld has no -soname; upstream suggests this alternative in the Makefile
        args << "VERSION_OPT=-Wl,-compatibility_version,$(LIBVER) -Wl,-current_version,$(VEREXT)"
      end
      system "make", *args
      system "make", "install", *args, "prefix=#{prefix}"
    end

    (lib/"pkgconfig/lmdb.pc").write pc_file
    (lib/"pkgconfig").install_symlink "lmdb.pc" => "liblmdb.pc"
  end

  def pc_file
    <<~PC
      prefix=#{opt_prefix}
      exec_prefix=${prefix}
      libdir=${prefix}/lib
      includedir=${prefix}/include

      Name: lmdb
      Description: #{desc}
      URL: #{homepage}
      Version: #{version}
      Libs: -L${libdir} -llmdb
      Cflags: -I${includedir}
    PC
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mdb_dump -V")

    # Make sure our `lmdb.pc` can be read by `pkg-config`.
    system "pkg-config", "lmdb"
  end
end
