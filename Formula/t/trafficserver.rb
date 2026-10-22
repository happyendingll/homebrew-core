class Trafficserver < Formula
  desc "HTTP/1.1 and HTTP/2 compliant caching proxy server"
  homepage "https://trafficserver.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=trafficserver/trafficserver-10.2.1.tar.bz2"
  mirror "https://archive.apache.org/dist/trafficserver/trafficserver-10.2.1.tar.bz2"
  sha256 "352957dc55cab2dd9accfa6b02f1c827109a6b6bb34607381743dbfb8de3b87f"
  license "Apache-2.0"
  head "https://github.com/apache/trafficserver.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 sequoia: "83f04627415ca7ec8d7c5f58a7ae1f821e9aa8e5aa2b6eb777f087d057aa0dee"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "brotli"
  depends_on "hwloc"
  depends_on "imagemagick"
  depends_on "libmaxminddb"
  depends_on "luajit"
  depends_on "nuraft"
  depends_on "openssl@4"
  depends_on "pcre2"
  depends_on "xz"
  depends_on "yaml-cpp"
  depends_on "zstd"

  uses_from_macos "flex" => :build
  uses_from_macos "ncurses"

  on_linux do
    depends_on "libcap"
    depends_on "libunwind"
    depends_on "zlib-ng-compat"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_EXPERIMENTAL_PLUGINS=ON",
                    "-DCMAKE_INSTALL_LOCALSTATEDIR=#{var}",
                    "-DCMAKE_INSTALL_RUNSTATEDIR=#{var}/run/trafficserver",
                    "-DEXTERNAL_YAML_CPP=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # CMAKE_INSTALL_SYSCONFDIR doesn't work as install_configs.cmake prepends the prefix
    configs = (prefix/"etc/trafficserver").children.select(&:file?)
    pkgetc.install configs
    (prefix/"etc/trafficserver").install_symlink configs.map { |config| pkgetc/config.basename }

    (var/"log/trafficserver").mkpath
    (var/"run/trafficserver").mkpath
    (var/"trafficserver").mkpath
  end

  test do
    if OS.mac?
      output = shell_output("#{bin}/trafficserver status")
      assert_match "Apache Traffic Server is not running", output
    else
      output = shell_output("#{bin}/trafficserver status 2>&1", 3)
      assert_match "traffic_server is not running", output
    end
  end
end
