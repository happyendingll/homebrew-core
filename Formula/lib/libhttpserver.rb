class Libhttpserver < Formula
  desc "C++ library of embedded Rest HTTP server"
  homepage "https://github.com/etr/libhttpserver"
  url "https://github.com/etr/libhttpserver/releases/download/2.0.1/libhttpserver-2.0.1.tar.gz"
  sha256 "767716a689b5078a9e6ad4e6dc5c2708a50c79f195fce599dd80e35566c8f64a"
  license "LGPL-2.1-or-later"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-3"
    sha256 cellar: :any, sequoia: "32ef4327707446a9fb9e13d9ca6005f0615987870ac7cf28f78f6e98e177e265"
  end

  head do
    url "https://github.com/etr/libhttpserver.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "gnutls"
  depends_on "libmicrohttpd"

  uses_from_macos "curl" => :test

  allow_network_access! :test

  def install
    system "./bootstrap" if build.head?
    mkdir "build" do
      system "../configure", "--disable-silent-rules", *std_configure_args
      system "make", "install"
    end
    pkgshare.install "examples"
  end

  test do
    port = free_port

    cp pkgshare/"examples/hello_world.cpp", testpath
    inreplace "hello_world.cpp", "create_webserver(8080)", "create_webserver(#{port})"

    system ENV.cxx, "hello_world.cpp",
      "-std=c++20", "-o", "hello_world", "-L#{lib}", "-lhttpserver", "-lcurl"

    pid = spawn "./hello_world"

    assert_match "Hello, World!",
                 shell_output("curl --silent --show-error --retry 5 --retry-connrefused http://127.0.0.1:#{port}/hello")
  ensure
    Process.kill "TERM", pid
    Process.wait pid
  end
end
