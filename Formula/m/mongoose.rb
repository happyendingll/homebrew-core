class Mongoose < Formula
  desc "Web server build on top of Libmongoose embedded library"
  homepage "https://mongoose.ws/"
  url "https://github.com/cesanta/mongoose/archive/refs/tags/7.24.tar.gz"
  sha256 "0b21cc2ac2a094600d58f2bd20d42aa21ce88375adefc32af481fe89997285fb"
  license "GPL-2.0-only"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "83bab77e25d6efaf9084c55f81695ef9f02e90ac4120abba3b5fcb07fe6e0faf"
  end

  allow_network_access! :test

  def install
    # No Makefile but is an expectation upstream of binary creation
    # https://github.com/cesanta/mongoose/issues/326
    system "make", "-C", "tutorials/http/http-server", "example"
    bin.install "tutorials/http/http-server/example" => "mongoose"

    system ENV.cc, "-dynamiclib", "mongoose.c", "-o", "libmongoose.dylib" if OS.mac?
    if OS.linux?
      system ENV.cc, "-fPIC", "-c", "mongoose.c"
      system ENV.cc, "-shared", "-Wl,-soname,libmongoose.so", "-o", "libmongoose.so", "mongoose.o", "-lc", "-lpthread"
    end
    lib.install shared_library("libmongoose")
    include.install "mongoose.h"
    pkgshare.install "tutorials"
    doc.install Dir["docs/*"]

    # Remove tutorials which have binaries built for a non-native architecture
    rm_r pkgshare/"tutorials/stm32/nucleo-n657x0-q/" if OS.linux?
  end

  test do
    (testpath/"hello.html").write <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Homebrew</title>
        </head>
        <body>
          <p>Hi!</p>
        </body>
      </html>
    HTML

    begin
      pid = fork { exec bin/"mongoose" }
      sleep 2
      assert_match "Hi!", shell_output("curl http://localhost:8000/hello.html")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
