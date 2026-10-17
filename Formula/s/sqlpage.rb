class Sqlpage < Formula
  desc "Web app builder using SQL queries to create dynamic webapps quickly"
  homepage "https://sql-page.com/"
  url "https://github.com/sqlpage/SQLpage/archive/refs/tags/v0.47.0.tar.gz"
  sha256 "cb5db9c6589999d9d07f19e4cd49383a59a7625bfe5ed1a7a4b2bef21afccd76"
  license "MIT"
  head "https://github.com/sqlpage/SQLpage.git", branch: "main"

  bottle do
    root_url "https://github.com/happyendingll/intel-bottles/releases/download/bottles-3"
    sha256 cellar: :any, sequoia: "a1f3fa2c37980d8cacf25a9e6ea820ae2aa081097123accb2e6c10b2cfbb6638"
  end

  depends_on "node" => :build
  depends_on "rust" => :build
  depends_on "unixodbc"

  allow_network_access! :test

  def fetch
    system "npm", "ci", *std_npm_args(prefix: false)
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "npm", "run", "build"
    system "cargo", "install", *std_cargo_args
  end

  test do
    port = free_port

    ENV["PORT"] = port.to_s
    pid = spawn bin/"sqlpage"

    assert_match "It works", shell_output("curl --retry-connrefused --retry 4 --silent http://localhost:#{port}")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
