class AndroidFileTransferLinux < Formula
  desc "Command-line MTP client for Android and other MTP devices"
  homepage "https://whoozle.github.io/android-file-transfer-linux/"
  url "https://github.com/whoozle/android-file-transfer-linux/archive/refs/tags/v4.6.tar.gz"
  sha256 "d8bcbd1ea5854e2653661f7e953c955531eed540ca9aee966ae9bb64149f69e4"
  license "LGPL-2.1-or-later"
  head "https://github.com/whoozle/android-file-transfer-linux.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "8623249c8134dc09b090bc13d9407b35c073ffebfb0999ca9875dd73cf9a74d8"
  end

  depends_on "cmake" => :build
  depends_on "readline"

  deny_network_access!

  def install
    args = %w[
      -DBUILD_FUSE=OFF
      -DBUILD_MTPZ=OFF
      -DBUILD_PYTHON=OFF
      -DBUILD_QT_UI=OFF
      -DBUILD_SHARED_LIB=ON
      -DBUILD_TAGLIB=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "batch command processing", shell_output("#{bin}/aft-mtp-cli --help 2>&1")
    output = pipe_output("#{bin}/aft-mtp-cli -b -d homebrew-test-no-device 2>&1", "quit", 1)
    assert_match "device not found", output
  end
end
