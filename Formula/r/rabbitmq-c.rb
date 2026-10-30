class RabbitmqC < Formula
  desc "C AMQP client library for RabbitMQ"
  homepage "https://github.com/alanxz/rabbitmq-c"
  url "https://github.com/alanxz/rabbitmq-c/archive/refs/tags/v0.18.1.tar.gz"
  sha256 "0779bd4f00175ff2f722f9dc43b542bea3bc606ed079e7099fa8a18627c2ddc9"
  license "MIT"
  compatibility_version 1
  head "https://github.com/alanxz/rabbitmq-c.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "5f537e7465d459f0ef7fbad60d50bc1fd5c60d96baff355836b6104dee15f2ea"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "xmlto" => :build
  depends_on "openssl@4"
  depends_on "popt"

  deny_network_access!

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_API_DOCS=OFF",
                    "-DBUILD_EXAMPLES=OFF",
                    "-DBUILD_TESTS=OFF",
                    "-DBUILD_TOOLS=ON",
                    "-DBUILD_TOOLS_DOCS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system bin/"amqp-get", "--help"
  end
end
