class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "https://zlib.net/"
  url "https://zlib.net/zlib-1.4.tar.gz"
  mirror "https://github.com/madler/zlib/releases/download/v1.4/zlib-1.4.tar.gz"
  sha256 "02dd159783677a749c04adbdd02b55b8a2bcc7e054f51b76b549199a916ad584"
  license "Zlib"
  compatibility_version 1
  head "https://github.com/madler/zlib.git", branch: "develop"

  livecheck do
    url :homepage
    regex(/href=.*?zlib[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "738ba9b79f12c3041caa917d8e9f447c04d059f0e91e902c310b25ae59e4f138"
  end

  keg_only :provided_by_macos

  on_linux do
    keg_only "it conflicts with zlib-ng-compat"
  end

  # https://zlib.net/zlib_how.html
  resource "zpipe.c", :test do
    url "https://raw.githubusercontent.com/madler/zlib/99623ef7097352da7993ba614161fd6a311e046e/examples/zpipe.c"
    sha256 "e79717cefd20043fb78d730fd3b9d9cdf8f4642307fc001879dc82ddb468509f"
  end

  # `test do` block downloads a test fixture resource
  allow_network_access! :test

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Avoid rebuilds of dependents that hardcode this path.
    inreplace lib/"pkgconfig/zlib.pc", prefix, opt_prefix
  end

  test do
    testpath.install resource("zpipe.c")
    system ENV.cc, "zpipe.c", "-I#{include}", "-L#{lib}", "-lz", "-o", "zpipe"

    text = "Hello, Homebrew!"
    compressed = pipe_output("./zpipe", text, 0)
    assert_equal text, pipe_output("./zpipe -d", compressed, 0)
  end
end
