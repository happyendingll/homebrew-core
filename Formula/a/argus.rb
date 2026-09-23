class Argus < Formula
  desc "Audit Record Generation and Utilization System server"
  homepage "https://openargus.org"
  url "https://github.com/openargus/argus/archive/refs/tags/v5.0.4.tar.gz"
  sha256 "9c3863fd44fd2912dd763002fbe733259564b00b9b7c66b2e9b970bf2a41232d"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "48eaddd89c6b5a98fb64240d25a9ad4f8f82499d4e7c12df9fcab443a6aa4440"
  end

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "cyrus-sasl"
  uses_from_macos "libpcap"

  on_linux do
    depends_on "libtirpc"
    depends_on "zlib-ng-compat"
  end

  def install
    if OS.linux?
      ENV.append_to_cflags "-I#{formula_opt_include("libtirpc")}/tirpc"
      ENV.append "LIBS", "-ltirpc"
    end
    system "./configure", "--with-sasl", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    assert_match "Pages", shell_output(bin/"argus-vmstat") if OS.mac?
    assert_match "Argus Version #{version}", shell_output("#{sbin}/argus -h", 255)
    system sbin/"argus", "-r", test_fixtures("test.pcap"), "-w", testpath/"test.argus"
    assert_path_exists testpath/"test.argus"
  end
end
