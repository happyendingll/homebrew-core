class Gost < Formula
  desc "GO Simple Tunnel - a simple tunnel written in golang"
  homepage "https://gost.run/"
  url "https://github.com/go-gost/gost/archive/refs/tags/v3.3.0.tar.gz"
  sha256 "2a65e2da14fef6b6da8d4e32a8bc62e39970dbb141db42bc6f5821f90ac1e9a3"
  license "MIT"
  head "https://github.com/go-gost/gost.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-1"
    sha256 cellar: :any_skip_relocation, sequoia: "52063d8588bc679751eafffab0f8316b4d95ec26d8085d94ef0712679750f9a4"
  end

  depends_on "go" => :build

  conflicts_with "vulsio-gost", because: "both install `gost` binaries"

  def install
    system "go", "build", *std_go_args, "./cmd/gost"
    prefix.install "README_en.md"

    etc.install "gost.yml"
  end

  def caveats
    <<~EOS
      The config is installed to #{etc}/gost.yml.
    EOS
  end

  service do
    run [opt_bin/"gost", "-C", etc/"gost.yml"]
    keep_alive true
  end

  test do
    bind_address = "127.0.0.1:#{free_port}"
    (testpath/"gost.yml").write <<~YAML
      services:
        - name: test
          addr: "#{bind_address}"
          handler:
            type: auto
          listener:
            type: tcp
    YAML
    pid = spawn bin/"gost", "-C", testpath/"gost.yml"
    sleep 2
    output = shell_output("curl --max-time 10 -I -x #{bind_address} https://github.com")
    assert_match %r{HTTP/\d+(?:\.\d+)? 200}, output
    assert_match(/Server: GitHub.com/i, output)

    output = shell_output("curl --max-time 10 -I --socks5-hostname #{bind_address} https://github.com")
    assert_match %r{HTTP/\d+(?:\.\d+)? 200}, output
    assert_match(/Server: GitHub.com/i, output)
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
