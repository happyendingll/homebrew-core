class Pkgsite < Formula
  desc "Documentation server for Go packages"
  homepage "https://pkg.go.dev/golang.org/x/pkgsite"
  url "https://github.com/golang/pkgsite/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "ec88faa9940cdcd58ed15058a1a932f81b4c3a21cf37b3119bf974a3137373fd"
  license "BSD-3-Clause"
  head "https://go.googlesource.com/pkgsite.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-warm-2"
    sha256 cellar: :any_skip_relocation, sequoia: "5f3ad0486ccb8139a4f8a0ea7dafaac27fa7cb0debf978e065da334ade4b2f10"
  end

  depends_on "go" => [:build, :test]

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/pkgsite"
  end

  test do
    require "socket"
    require "timeout"

    port = free_port

    testmod_path = testpath/"testmod"
    testmod_path.mkpath

    (testmod_path/"go.mod").write <<~MOD
      module example.com/testmod

      go 1.26
    MOD

    (testmod_path/"main.go").write <<~GO
      package main

      func Hello() string { return "hi" }
    GO

    pid = spawn bin/"pkgsite", "-http", "127.0.0.1:#{port}", "-cache", testmod_path

    Timeout.timeout(60) do
      loop do
        TCPSocket.new("127.0.0.1", port).close
        break
      rescue Errno::ECONNREFUSED
        sleep 0.2
      end
    end

    raise "pkgsite exited unexpectedly" if Process.waitpid(pid, Process::WNOHANG)

    package_output = shell_output("curl -s http://127.0.0.1:#{port}/v1/package/example.com/testmod")
    assert_match '"modulePath":"example.com/testmod"', package_output

    symbols_output = shell_output("curl -s http://127.0.0.1:#{port}/v1/symbols/example.com/testmod")
    assert_match '"name":"Hello"', symbols_output
    assert_match '"kind":"Function"', symbols_output
    assert_match "func Hello() string", symbols_output
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
