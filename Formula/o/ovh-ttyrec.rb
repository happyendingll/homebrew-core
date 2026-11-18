class OvhTtyrec < Formula
  desc "Enhanced (but compatible) version of the classic ttyrec"
  homepage "https://github.com/ovh/ovh-ttyrec"
  url "https://github.com/ovh/ovh-ttyrec/archive/refs/tags/v1.2.0.1.tar.gz"
  sha256 "d6b841c8d01f8d8a744f585ac765f2837054ed0a190cc0985d81e74972becc3a"
  license all_of: ["BSD-3-Clause", "BSD-4-Clause-UC"]
  compatibility_version 1

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "cb09546ca80bd31a434cb48439258ac74065482f37c35fd9d7f7dc8633919097"
  end

  depends_on "zstd"

  conflicts_with "ttyrec", because: "both install the same binaries"

  deny_network_access!

  def install
    ENV["NO_STATIC_ZSTD"] = "1"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.tty").binwrite([0, 0, 4].pack("V3") + "test" + [9, 0, 3].pack("V3") + "end")

    assert_equal "9\ttest.tty", shell_output("#{bin}/ttytime test.tty").strip
  end
end
