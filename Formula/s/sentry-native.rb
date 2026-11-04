class SentryNative < Formula
  desc "Sentry SDK for C, C++ and native applications"
  homepage "https://docs.sentry.io/platforms/native/"
  url "https://github.com/getsentry/sentry-native/releases/download/0.17.6/sentry-native.zip"
  sha256 "40b4b70cbada5bfae5b73f8267831dd023ec676d9676fb0d890878f31d2b5055"
  license "MIT"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-5"
    sha256 cellar: :any, sequoia: "1d195015f50d6867fefbe8f3cda5699f1a4e9c20e76ff53a938ba5b7d22b790d"
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
