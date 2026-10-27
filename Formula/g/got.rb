class Got < Formula
  desc "Version control system"
  homepage "https://gameoftrees.org/", browsed: "2026-10-17"
  url "https://gameoftrees.org/releases/portable/got-portable-0.130.1.tar.gz"
  mirror "https://pkg.freebsd.org/ports-distfiles/got-portable-0.130.1.tar.gz"
  sha256 "43c5fba2f3791e3cef202803baa819fd29c53c4ba1f89f90582e06c6a443beb4"
  license "ISC"

  # Since GitHub runners are not able to access the homepage, our Linux build
  # requires FreeBSD mirror to exist before we can bump the version.
  livecheck do
    url "https://raw.githubusercontent.com/freebsd/freebsd-ports/refs/heads/main/devel/got/distinfo"
    regex(/got-portable[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  no_autobump! because: "GitHub runners are not abile to access the homepage or livecheck URL"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 sequoia: "60cf0e822be370fcca64b0fbefe06cb4bb7632664b3e452aeb30fd37d8ff5ab9"
  end

  depends_on "bison" => :build
  depends_on "pkgconf" => :build
  depends_on "libevent"
  depends_on "libretls"
  depends_on "ncurses"
  depends_on "openssl@4"

  on_linux do
    depends_on "libbsd"
    depends_on "libmd"
    depends_on "util-linux" # for libuuid
    depends_on "zlib-ng-compat"
  end

  deny_network_access!

  def install
    # `configure` hardcodes Homebrew's `openssl@3` paths on macOS
    inreplace "configure", "openssl@3", "openssl@4"

    ENV["LIBTLS_CFLAGS"] = "-I#{formula_opt_include("libretls")}"
    ENV["LIBTLS_LIBS"] = "-L#{formula_opt_lib("libretls")} -ltls"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    ENV["GOT_AUTHOR"] = "Flan Hacker <flan_hacker@openbsd.org>"
    system bin/"gotadmin", "init", "repo.git"
    mkdir "import-dir"
    %w[haunted house].each { |f| touch testpath/"import-dir"/f }
    system bin/"got", "import", "-m", "Initial Commit", "-r", "repo.git", "import-dir"
    system bin/"got", "checkout", "repo.git", "src"
  end
end
