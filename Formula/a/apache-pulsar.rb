class ApachePulsar < Formula
  desc "Cloud-native distributed messaging and streaming platform"
  homepage "https://pulsar.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=pulsar/pulsar-5.0.1/apache-pulsar-5.0.1-src.tar.gz"
  mirror "https://archive.apache.org/dist/pulsar/pulsar-5.0.1/apache-pulsar-5.0.1-src.tar.gz"
  sha256 "687e2670dfb71ad10fd9972957de7426e4596a095b08781364950c4aa3fcafde"
  license "Apache-2.0"
  head "https://github.com/apache/pulsar.git", branch: "master"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-4"
    sha256 cellar: :any_skip_relocation, sequoia: "623743314af899284451543cd59799514cc11ee10f8f3b894798665c4ffcb01d"
  end

  depends_on "gradle" => :build
  depends_on "openjdk@25"

  uses_from_macos "zip" => :build

  deny_network_access! :postinstall

  def install
    java_home_env = Language::Java.java_home_env("25")
    ENV["JAVA_HOME"] = java_home_env[:JAVA_HOME]

    system "gradle", ":distribution:pulsar-server-distribution:assemble", "--no-daemon"
    tarball = Dir["distribution/server/build/distributions/apache-pulsar-*-bin.tar.gz"].first

    libexec.mkpath
    system "tar", "--extract", "--file", tarball, "--directory", libexec, "--strip-components=1"
    pkgshare.install libexec/"examples"
    (etc/"pulsar").install_symlink libexec/"conf"

    rm libexec.glob("bin/*.cmd")
    libexec.glob("bin/*") do |path|
      next if !path.file? || path.fnmatch?("*common.sh")

      (bin/path.basename).write_env_script path, java_home_env
    end

    (var/"log/pulsar").mkpath
  end

  service do
    run [opt_bin/"pulsar", "standalone"]
    log_path var/"log/pulsar/output.log"
    error_log_path var/"log/pulsar/error.log"
  end

  test do
    ENV["PULSAR_GC_LOG"] = "-Xlog:gc*:#{testpath}/pulsar_gc_%p.log:time,uptime:filecount=10,filesize=20M"
    ENV["PULSAR_LOG_DIR"] = testpath
    ENV["PULSAR_STANDALONE_USE_ZOOKEEPER"] = "1"

    pid = spawn bin/"pulsar", "standalone", "--zookeeper-dir", testpath/"zk", "--bookkeeper-dir", testpath/"bk"
    # The daemon takes some time to start; pulsar-client will retry until it gets a connection, but emit confusing
    # errors until that happens, so sleep to reduce log spam.
    sleep 30

    output = shell_output("#{bin}/pulsar-client produce my-topic --messages 'hello-pulsar'")
    assert_match "1 messages successfully produced", output
    output = shell_output("#{bin}/pulsar initialize-cluster-metadata -c a -cs localhost -uw localhost -zk localhost")
    assert_match "Cluster metadata setup correctly {cluster=a}", output
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
