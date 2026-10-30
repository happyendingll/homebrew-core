class Icestorm < Formula
  desc "Tools for analyzing and creating Lattice iCE40 FPGA bitstream files"
  homepage "https://prjicestorm.readthedocs.io"
  url "https://github.com/YosysHQ/icestorm/archive/refs/tags/v1.1.tar.gz"
  sha256 "928dd541d15540a796a3d320122794d8d76acff90783de8c5747f613e474652f"
  license "ISC"
  revision 1
  compatibility_version 1
  head "https://github.com/YosysHQ/icestorm.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "45bc17111bae6bddb0b4e0ca75049f36d98b3b74a8bd5e6e55181d25ace3ed11"
  end

  depends_on "pkgconf" => :build
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "python@3.15"

  def install
    system "make", "install", "PREFIX=#{prefix}"

    (pkgshare/"python").install bin.glob("icebox*")
    rm bin.glob("icebox*")
    bin.install_symlink pkgshare.glob("python/icebox_*")

    mv share/"icebox", pkgshare/"chipdb"
  end

  test do
    (testpath/"test.asc").write <<~ASC
      .device 1k
      .io_tile 1 0
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
      000000000000000000
    ASC
    system bin/"icepack", "test.asc", "test.bin"
    preamble = (testpath/"test.bin").binread(4).unpack("C*")
    assert_equal [0x7e, 0xaa, 0x99, 0x7e], preamble
  end
end
