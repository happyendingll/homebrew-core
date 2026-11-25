class Zookeeper < Formula
  desc "Centralized server for distributed coordination of services"
  homepage "https://zookeeper.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=zookeeper/zookeeper-3.10.0/apache-zookeeper-3.10.0.tar.gz"
  mirror "https://archive.apache.org/dist/zookeeper/zookeeper-3.10.0/apache-zookeeper-3.10.0.tar.gz"
  sha256 "a94a9ccc4f2816ac4ebcf9083da85fd9ddf4dac3422ca2bd79d696bea1a5fbc1"
  license "Apache-2.0"
  compatibility_version 1
  head "https://gitbox.apache.org/repos/asf/zookeeper.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-7"
    sha256 cellar: :any, sequoia: "86f4acf18067a3ad6cff256779608a355249f24b6c15b0f9e4e5caa4c6e40039"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cppunit" => :build
  depends_on "libtool" => :build
  depends_on "maven" => :build
  depends_on "pkgconf" => :build

  depends_on "openjdk"
  depends_on "openssl@4"

  deny_network_access!

  def fetch
    system "mvn", "dependency:go-offline", "-Pfull-build"
  end

  def install
    openssl_prefix = dep("openssl").opt_prefix
    system "mvn", "install", "-Pfull-build", "-DskipTests", "-Dc-client-openssl=#{openssl_prefix}"

    system "tar", "-xf", "zookeeper-assembly/target/apache-zookeeper-#{version}-bin.tar.gz"
    binpfx = "apache-zookeeper-#{version}-bin"
    libexec.install binpfx+"/bin", binpfx+"/lib", "zookeeper-contrib"
    rm(Dir["build-bin/bin/*.cmd"])

    system "tar", "-xf", "zookeeper-assembly/target/apache-zookeeper-#{version}-lib.tar.gz"
    libpfx = "apache-zookeeper-#{version}-lib"
    include.install Dir[libpfx+"/usr/include/*"]
    lib.install Dir[libpfx+"/usr/lib/*"]

    (var/"log/zookeeper").mkpath
    (var/"run/zookeeper/data").mkpath

    libexec.glob("bin/*.sh") do |path|
      next if path == libexec/"bin/zkEnv.sh"

      script_name = path.basename
      bin_name    = path.basename ".sh"
      (bin/bin_name).write <<~BASH
        #!/bin/bash
        export JAVA_HOME="${JAVA_HOME:-#{formula_opt_prefix("openjdk")}}"
        . "#{pkgetc}/defaults"
        exec "#{libexec}/bin/#{script_name}" "$@"
      BASH
    end

    (buildpath/"defaults").write <<~ZSH
      [ -z "$ZOOCFGDIR" ] && export ZOOCFGDIR="#{pkgetc}"
    ZSH
    cp "conf/logback.xml", "logback.xml"
    cp "conf/zoo_sample.cfg", "conf/zoo.cfg"
    inreplace "conf/zoo.cfg",
              /^dataDir=.*/, "dataDir=#{var}/run/zookeeper/data"
    pkgetc.install "conf/zoo.cfg", "defaults", "logback.xml"
    (pkgshare/"examples").install "conf/logback.xml", "conf/zoo_sample.cfg"
  end

  service do
    run [opt_bin/"zkServer", "start-foreground"]
    environment_variables SERVER_JVMFLAGS: "-Dapple.awt.UIElement=true"
    keep_alive successful_exit: false
    working_dir var
  end

  test do
    output = shell_output("#{bin}/zkServer -h 2>&1")
    assert_match "Using config: #{pkgetc}/zoo.cfg", output
  end
end
