class Mpich < Formula
  desc "Implementation of the MPI Message Passing Interface standard"
  homepage "https://www.mpich.org/"
  url "https://www.mpich.org/static/downloads/5.0.2/mpich-5.0.2.tar.gz"
  mirror "https://github.com/pmodels/mpich/releases/download/v5.0.2/mpich-5.0.2.tar.gz"
  sha256 "928c2f18d350a91443fe8024ad01ce2c6009e9c551e0a73e797fc567f119137d"
  license "mpich2"

  livecheck do
    url "https://www.mpich.org/static/downloads/"
    regex(%r{href=.*?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any, sequoia: "31828d5790faa0927dae2dff1580b1b11aa5f400dfc2dae8b9be76cdc1b6d6dd"
  end

  head do
    url "https://github.com/pmodels/mpich.git", branch: "main"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  depends_on "gcc" # for gfortran
  depends_on "hwloc"
  uses_from_macos "python" => :build

  on_macos do
    conflicts_with "libfabric", because: "both install `fabric.h`"
  end

  on_linux do
    # Can't be enabled on mac:
    # https://lists.mpich.org/pipermail/discuss/2021-May/006192.html
    depends_on "libfabric"
  end

  conflicts_with "open-mpi", because: "both install MPI compiler wrappers"

  def install
    if build.head?
      # ensure that the consistent set of autotools built by homebrew is used to
      # build MPICH, otherwise very bizarre build errors can occur
      ENV["MPICH_AUTOTOOLS_DIR"] = HOMEBREW_PREFIX + "bin"
      system "./autogen.sh"
    end

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-fast=all,O3
      --enable-g=dbg
      --enable-romio
      --enable-shared
      --with-hwloc=#{formula_opt_prefix("hwloc")}
      --with-pm=hydra
      --prefix=#{prefix}
      --mandir=#{man}
      F77=gfortran
      FC=gfortran
    ]

    if OS.linux?
      # Use libfabric https://lists.mpich.org/pipermail/discuss/2021-January/006092.html
      args << "--with-device=ch4:ofi"
      args << "--with-libfabric=#{formula_opt_prefix("libfabric")}"
    end

    system "./configure", *args

    system "make"
    system "make", "install"
  end

  test do
    (testpath/"hello.c").write <<~C
      #include <mpi.h>
      #include <stdio.h>

      int main()
      {
        int size, rank, nameLen;
        char name[MPI_MAX_PROCESSOR_NAME];
        MPI_Init(NULL, NULL);
        MPI_Comm_size(MPI_COMM_WORLD, &size);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        MPI_Get_processor_name(name, &nameLen);
        printf("[%d/%d] Hello, world! My name is %s.\\n", rank, size, name);
        MPI_Finalize();
        return 0;
      }
    C
    system bin/"mpicc", "hello.c", "-o", "hello"
    system "./hello"
    system bin/"mpirun", "-np", "4", "./hello"

    (testpath/"hellof.f90").write <<~FORTRAN
      program hello
      include 'mpif.h'
      integer rank, size, ierror, tag, status(MPI_STATUS_SIZE)
      call MPI_INIT(ierror)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierror)
      print*, 'node', rank, ': Hello Fortran world'
      call MPI_FINALIZE(ierror)
      end
    FORTRAN
    system bin/"mpif90", "hellof.f90", "-o", "hellof"
    system "./hellof"
    system bin/"mpirun", "-np", "4", "./hellof"
  end
end
