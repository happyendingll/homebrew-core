class SentryNative < Formula
  desc "Sentry SDK for C, C++ and native applications"
  homepage "https://docs.sentry.io/platforms/native/"
  url "https://github.com/getsentry/sentry-native/releases/download/0.17.7/sentry-native.zip"
  sha256 "abd241373670bcdc35d8ecf8e557dd1555eb38e1e65e3925fdbe36265b9438bf"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "503929f4d79ef3db7db50362bdf3c86cfce5d24c2d1c22913ffab4ebd67b5311"
  end

  depends_on "cmake" => :build

  uses_from_macos "curl"

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "libunwind"
    depends_on "zlib-ng-compat"
  end

  allow_network_access! :test

  def install
    rm_r("vendor/libunwind")

    args = %w[
      -DSENTRY_BUILD_EXAMPLES=OFF
      -DSENTRY_BUILD_TESTS=OFF
    ]
    args << "-DSENTRY_LIBUNWIND_SYSTEM=ON" if OS.linux?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <sentry.h>
      int main() {
        sentry_options_t *options = sentry_options_new();
        sentry_options_set_dsn(options, "https://ABC.ingest.us.sentry.io/123");
        sentry_init(options);
        sentry_close();
        return 0;
      }
    C

    system ENV.cc, "test.c", "-I#{HOMEBREW_PREFIX}/include", "-L#{HOMEBREW_PREFIX}/lib", "-lsentry", "-o", "test"
    system "./test"
  end
end
